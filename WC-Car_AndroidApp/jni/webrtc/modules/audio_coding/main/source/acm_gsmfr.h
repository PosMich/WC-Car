/*
 *  Copyright (c) 2012 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#ifndef WEBRTC_MODULES_AUDIO_CODING_MAIN_SOURCE_ACM_GSMFR_H_
#define WEBRTC_MODULES_AUDIO_CODING_MAIN_SOURCE_ACM_GSMFR_H_

#include "/var/www/QPT2b/WC-Car/WC-Car_AndroidApp/jni/webrtc/modules/audio_coding/main/source/acm_generic_codec.h"

// forward declaration
struct GSMFR_encinst_t_;
struct GSMFR_decinst_t_;

namespace webrtc {

class ACMGSMFR : public ACMGenericCodec {
 public:
  explicit ACMGSMFR(WebRtc_Word16 codec_id);
  ~ACMGSMFR();

  // for FEC
  ACMGenericCodec* CreateInstance(void);

  WebRtc_Word16 InternalEncode(WebRtc_UWord8* bitstream,
                               WebRtc_Word16* bitstream_len_byte);

  WebRtc_Word16 InternalInitEncoder(WebRtcACMCodecParams *codec_params);

  WebRtc_Word16 InternalInitDecoder(WebRtcACMCodecParams *codec_params);

 protected:
  WebRtc_Word16 DecodeSafe(WebRtc_UWord8* bitstream,
                           WebRtc_Word16 bitstream_len_byte,
                           WebRtc_Word16* audio,
                           WebRtc_Word16* audio_samples,
                           WebRtc_Word8* speech_type);

  WebRtc_Word32 CodecDef(WebRtcNetEQ_CodecDef& codec_def,
                         const CodecInst& codec_inst);

  void DestructEncoderSafe();

  void DestructDecoderSafe();

  WebRtc_Word16 InternalCreateEncoder();

  WebRtc_Word16 InternalCreateDecoder();

  void InternalDestructEncoderInst(void* ptr_inst);

  WebRtc_Word16 EnableDTX();

  WebRtc_Word16 DisableDTX();

  GSMFR_encinst_t_* encoder_inst_ptr_;
  GSMFR_decinst_t_* decoder_inst_ptr_;
};

}  // namespace webrtc

#endif  // WEBRTC_MODULES_AUDIO_CODING_MAIN_SOURCE_ACM_GSMFR_H_
