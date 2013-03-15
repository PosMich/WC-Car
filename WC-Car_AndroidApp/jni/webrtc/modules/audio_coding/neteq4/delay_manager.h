/*
 *  Copyright (c) 2012 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#ifndef WEBRTC_MODULES_AUDIO_CODING_NETEQ4_DELAY_MANAGER_H_
#define WEBRTC_MODULES_AUDIO_CODING_NETEQ4_DELAY_MANAGER_H_

#include <cstring>  // Provide access to size_t.
#include <vector>

#include "/var/www/QPT2b/WC-Car/WC-Car_AndroidApp/jni/webrtc/modules/audio_coding/neteq4/interface/audio_decoder.h"
#include "/var/www/QPT2b/WC-Car/WC-Car_AndroidApp/jni/webrtc/system_wrappers/interface/constructor_magic.h"
#include "/var/www/QPT2b/WC-Car/WC-Car_AndroidApp/jni/webrtc/typedefs.h"

namespace webrtc {

// Forward declaration.
class DelayPeakDetector;

class DelayManager {
 public:
  typedef std::vector<int> IATVector;

  // Create a DelayManager object. Notify the delay manager that the packet
  // buffer can hold no more than |max_packets_in_buffer| packets (i.e., this
  // is the number of packet slots in the buffer). Supply a PeakDetector
  // object to the DelayManager.
  DelayManager(int max_packets_in_buffer, DelayPeakDetector* peak_detector);

  virtual ~DelayManager() {}

  // Read the inter-arrival time histogram. Mainly for testing purposes.
  virtual const IATVector& iat_vector() const { return iat_vector_; }

  // Updates the delay manager with a new incoming packet, with
  // |sequence_number| and |timestamp| from the RTP header. This updates the
  // inter-arrival time histogram and other statistics, as well as the
  // associated DelayPeakDetector. A new target buffer level is calculated.
  // Returns 0 on success, -1 on failure (invalid sample rate).
  virtual int Update(uint16_t sequence_number,
                     uint32_t timestamp,
                     int sample_rate_hz);

  // Calculates a new target buffer level. Called from the Update() method.
  // Sets target_level_ (in Q8) and returns the same value. Also calculates
  // and updates base_target_level_, which is the target buffer level before
  // taking delay peaks into account.
  virtual int CalculateTargetLevel(int iat_packets);

  // Notifies the DelayManager of how much audio data is carried in each packet.
  // The method updates the DelayPeakDetector too, and resets the inter-arrival
  // time counter. Returns 0 on success, -1 on failure.
  virtual int SetPacketAudioLength(int length_ms);

  // Resets the DelayManager and the associated DelayPeakDetector.
  virtual void Reset();

  // Calculates the average inter-arrival time deviation from the histogram.
  // The result is returned as parts-per-million deviation from the nominal
  // inter-arrival time. That is, if the average inter-arrival time is equal to
  // the nominal frame time, the return value is zero. A positive value
  // corresponds to packet spacing being too large, while a negative value means
  // that the packets arrive with less spacing than expected.
  virtual int AverageIAT() const;

  // Returns true if peak-mode is active. That is, delay peaks were observed
  // recently. This method simply asks for the same information from the
  // DelayPeakDetector object.
  virtual bool PeakFound() const;

  // Notifies the counters in DelayManager and DelayPeakDetector that
  // |elapsed_time_ms| have elapsed.
  virtual void UpdateCounters(int elapsed_time_ms);

  // Reset the inter-arrival time counter to 0.
  virtual void ResetPacketIatCount() { packet_iat_count_ms_ = 0; }

  // Writes the lower and higher limits which the buffer level should stay
  // within to the corresponding pointers. The values are in (fractions of)
  // packets in Q8.
  virtual void BufferLimits(int* lower_limit, int* higher_limit) const;

  // Gets the target buffer level, in (fractions of) packets in Q8. This value
  // includes any extra delay set through the set_extra_delay_ms() method.
  virtual int TargetLevel() const;

  virtual void LastDecoderType(NetEqDecoder decoder_type);

  // Accessors and mutators.
  virtual void set_extra_delay_ms(int16_t delay) { extra_delay_ms_ = delay; }
  virtual int base_target_level() const { return base_target_level_; }
  virtual void set_streaming_mode(bool value) { streaming_mode_ = value; }
  virtual int last_pack_cng_or_dtmf() const { return last_pack_cng_or_dtmf_; }
  virtual void set_last_pack_cng_or_dtmf(int value) {
    last_pack_cng_or_dtmf_ = value;
  }

 private:
  static const int kLimitProbability = 53687091;  // 1/20 in Q30.
  static const int kLimitProbabilityStreaming = 536871;  // 1/2000 in Q30.
  static const int kMaxStreamingPeakPeriodMs = 600000;  // 10 minutes in ms.
  static const int kCumulativeSumDrift = 2;  // Drift term for cumulative sum
                                             // |iat_cumulative_sum_|.
  // Steady-state forgetting factor for |iat_vector_|, 0.9993 in Q15.
  static const int kIatFactor_ = 32745;
  static const int kMaxIat = 64;  // Max inter-arrival time to register.

  // Sets |iat_vector_| to the default start distribution and sets the
  // |base_target_level_| and |target_level_| to the corresponding values.
  void ResetHistogram();

  // Updates |iat_cumulative_sum_| and |max_iat_cumulative_sum_|. (These are
  // used by the streaming mode.) This method is called by Update().
  void UpdateCumulativeSums(int packet_len_ms, uint16_t sequence_number);

  // Updates the histogram |iat_vector_|. The probability for inter-arrival time
  // equal to |iat_packets| (in integer packets) is increased slightly, while
  // all other entries are decreased. This method is called by Update().
  void UpdateHistogram(size_t iat_packets);

  // Makes sure that |target_level_| is not too large, taking
  // |max_packets_in_buffer_| and |extra_delay_ms_| into account. This method is
  // called by Update().
  void LimitTargetLevel();

  bool first_packet_received_;
  const int max_packets_in_buffer_;  // Capacity of the packet buffer.
  IATVector iat_vector_;  // Histogram of inter-arrival times.
  int iat_factor_;  // Forgetting factor for updating the IAT histogram (Q15).
  int packet_iat_count_ms_;  // Milliseconds elapsed since last packet.
  int base_target_level_;   // Currently preferred buffer level before peak
                            // detection and streaming mode (Q0).
  int target_level_;  // Currently preferred buffer level in (fractions)
                      // of packets (Q8), before adding any extra delay.
  int packet_len_ms_;  // Length of audio in each incoming packet [ms].
  bool streaming_mode_;
  uint16_t last_seq_no_;  // Sequence number for last received packet.
  uint32_t last_timestamp_;  // Timestamp for the last received packet.
  int extra_delay_ms_;  // Externally set extra delay.
  int iat_cumulative_sum_;  // Cumulative sum of delta inter-arrival times.
  int max_iat_cumulative_sum_;  // Max of |iat_cumulative_sum_|.
  int max_timer_ms_;  // Time elapsed since maximum was observed.
  DelayPeakDetector& peak_detector_;
  int last_pack_cng_or_dtmf_;

  DISALLOW_COPY_AND_ASSIGN(DelayManager);
};

}  // namespace webrtc
#endif  // WEBRTC_MODULES_AUDIO_CODING_NETEQ4_DELAY_MANAGER_H_
