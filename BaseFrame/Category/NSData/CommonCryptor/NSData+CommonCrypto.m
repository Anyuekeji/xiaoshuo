/*
 *  NSData+CommonCrypto.m
 *  AQToolkit
 *
 *  Created by Jim Dovey on 31/8/2008.
 *
 *  Copyright (c) 2008-2009, Jim Dovey
 *  All rights reserved.
 *  
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  Redistributions of source code must retain the above copyright notice,
 *  this list of conditions and the following disclaimer.
 *  
 *  Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the distribution.
 *  
 *  Neither the name of this project's author nor the names of its
 *  contributors may be used to endorse or promote products derived from
 *  this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
 *  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 *  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import <Foundation/Foundation.h>
#import "NSData+CommonCrypto.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

NSString * const kCommonCryptoErrorDomain = @"CommonCryptoErrorDomain";

@implementation NSError (CommonCryptoErrorDomain)

+ (NSError *) errorWithCCCryptorStatus: (CCCryptorStatus) status
{
	NSString * description = nil, * reason = nil;
	
	switch ( status )
	{
		case kCCSuccess:
			description = NSLocalizedString(@"Success", @"Error description");
			break;
			
		case kCCParamError:
			description = NSLocalizedString(@"Parameter Error", @"Error description");
			reason = NSLocalizedString(@"Illegal parameter supplied to encryption/decryption algorithm", @"Error reason");
			break;
			
		case kCCBufferTooSmall:
			description = NSLocalizedString(@"Buffer Too Small", @"Error description");
			reason = NSLocalizedString(@"Insufficient buffer provided for specified operation", @"Error reason");
			break;
			
		case kCCMemoryFailure:
			description = NSLocalizedString(@"Memory Failure", @"Error description");
			reason = NSLocalizedString(@"Failed to allocate memory", @"Error reason");
			break;
			
		case kCCAlignmentError:
			description = NSLocalizedString(@"Alignment Error", @"Error description");
			reason = NSLocalizedString(@"Input size to encryption algorithm was not aligned correctly", @"Error reason");
			break;
			
		case kCCDecodeError:
			description = NSLocalizedString(@"Decode Error", @"Error description");
			reason = NSLocalizedString(@"Input data did not decode or decrypt correctly", @"Error reason");
			break;
			
		case kCCUnimplemented:
			description = NSLocalizedString(@"Unimplemented Function", @"Error description");
			reason = NSLocalizedString(@"Function not implemented for the current algorithm", @"Error reason");
			break;
			
		default:
			description = NSLocalizedString(@"Unknown Error", @"Error description");
			break;
	}
	
	NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject: description forKey: NSLocalizedDescriptionKey];
	
	if ( reason != nil )
		[userInfo setObject: reason forKey: NSLocalizedFailureReasonErrorKey];
	
	NSError * result = [NSError errorWithDomain: kCommonCryptoErrorDomain code: status userInfo: userInfo];

	
	return ( result );
}

@end

#pragma mark -

@implementation NSData (CommonDigest)

- (NSData *) MD2Sum
{
	unsigned char hash[CC_MD2_DIGEST_LENGTH];
	(void) CC_MD2( [self bytes], (CC_LONG)[self length], hash );
	return ( [NSData dataWithBytes: hash length: CC_MD2_DIGEST_LENGTH] );
}

- (NSData *) MD4Sum
{
	unsigned char hash[CC_MD4_DIGEST_LENGTH];
	(void) CC_MD4( [self bytes], (CC_LONG)[self length], hash );
	return ( [NSData dataWithBytes: hash length: CC_MD4_DIGEST_LENGTH] );
}

- (NSData *) MD5Sum
{
	unsigned char hash[CC_MD5_DIGEST_LENGTH];
	(void) CC_MD5( [self bytes], (CC_LONG)[self length], hash );
	return ( [NSData dataWithBytes: hash length: CC_MD5_DIGEST_LENGTH] );
}

- (NSData *) SHA1Hash
{
	unsigned char hash[CC_SHA1_DIGEST_LENGTH];
	(void) CC_SHA1( [self bytes], (CC_LONG)[self length], hash );
	return ( [NSData dataWithBytes: hash length: CC_SHA1_DIGEST_LENGTH] );
}

- (NSData *) SHA224Hash
{
	unsigned char hash[CC_SHA224_DIGEST_LENGTH];
	(void) CC_SHA224( [self bytes], (CC_LONG)[self length], hash );
	return ( [NSData dataWithBytes: hash length: CC_SHA224_DIGEST_LENGTH] );
}

- (NSData *) SHA256Hash
{
	unsigned char hash[CC_SHA256_DIGEST_LENGTH];
	(void) CC_SHA256( [self bytes], (CC_LONG)[self length], hash );
	return ( [NSData dataWithBytes: hash length: CC_SHA256_DIGEST_LENGTH] );
}

- (NSData *) SHA384Hash
{
	unsigned char hash[CC_SHA384_DIGEST_LENGTH];
	(void) CC_SHA384( [self bytes], (CC_LONG)[self length], hash );
	return ( [NSData dataWithBytes: hash length: CC_SHA384_DIGEST_LENGTH] );
}

- (NSData *) SHA512Hash
{
	unsigned char hash[CC_SHA512_DIGEST_LENGTH];
	(void) CC_SHA512( [self bytes], (CC_LONG)[self length], hash );
	return ( [NSData dataWithBytes: hash length: CC_SHA512_DIGEST_LENGTH] );
}

@end

@implementation NSData (CommonCryptor)

- (NSData *) AES256EncryptedDataUsingKey: (id) key error: (NSError **) error
{
	CCCryptorStatus status = kCCSuccess;
	NSData * result = [self dataEncryptedUsingAlgorithm: kCCAlgorithmAES128
													key: key
                                                options: kCCOptionPKCS7Padding
												  error: &status];
	
	if ( result != nil )
		return ( result );
	
	if ( error != NULL )
		*error = [NSError errorWithCCCryptorStatus: status];
	
	return ( nil );
}

- (NSData *) decryptedAES256DataUsingKey: (id) key error: (NSError **) error
{
	CCCryptorStatus status = kCCSuccess;
	NSData * result = [self decryptedDataUsingAlgorithm: kCCAlgorithmAES128
													key: key
                                                options: kCCOptionPKCS7Padding
												  error: &status];
	
	if ( result != nil )
		return ( result );
	
	if ( error != NULL )
		*error = [NSError errorWithCCCryptorStatus: status];
	
	return ( nil );
}
//加密
- (NSData *)AES128EncryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128operation:kCCEncrypt key:key iv:iv];
}

//解密
- (NSData *)AES128DecryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128operation:kCCDecrypt key:key iv:iv];
}

- (NSData *)AES128operation:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv
{
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // IV
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    size_t bufferSize = [self length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    
    
    CCCryptorStatus cryptorStatus = CCCrypt(operation, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                            keyPtr, kCCKeySizeAES128,
                                            ivPtr,
                                            [self bytes], [self length],
                                            buffer, bufferSize,
                                            &numBytesEncrypted);
    
    if(cryptorStatus == kCCSuccess){
        NSLog(@"Success");
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        
    }else{
        NSLog(@"Error");
    }
    
    free(buffer);
    return nil;
}

- (NSString *) AES256EncryptedStringUsingKey: (id) key error: (NSError **) error
{
   NSData *aes256EncryData = [self AES256EncryptedDataUsingKey:key error:error];
    if (aes256EncryData)
    {
        return  [aes256EncryData base64EncodedStringWithOptions:0];
    }
    return nil;
}
- (NSString *) decryptedAES256StringUsingKey: (id) key error: (NSError **) error
{
    NSData *des256EncryptedData = [self decryptedAES256DataUsingKey:key error:error];
    if (des256EncryptedData)
    {
        return  [des256EncryptedData base64EncodedStringWithOptions:0];
    }
    return nil;
}
- (NSData *) DESEncryptedDataUsingKey: (id) key error: (NSError **) error
{
	CCCryptorStatus status = kCCSuccess;
	NSData * result = [self dataEncryptedUsingAlgorithm: kCCAlgorithmDES
													key: key
                                                options: kCCOptionPKCS7Padding
												  error: &status];
	
	if ( result != nil )
		return ( result );
	
	if ( error != NULL )
		*error = [NSError errorWithCCCryptorStatus: status];
	
	return ( nil );
}

- (NSData *) decryptedDESDataUsingKey: (id) key error: (NSError **) error
{
	CCCryptorStatus status = kCCSuccess;
	NSData * result = [self decryptedDataUsingAlgorithm: kCCAlgorithmDES
													key: key
                                                options: kCCOptionPKCS7Padding
												  error: &status];
	
	if ( result != nil )
		return ( result );
	
	if ( error != NULL )
		*error = [NSError errorWithCCCryptorStatus: status];
	
	return ( nil );
}
- (NSString *) DESEncryptedStringUsingKey: (id) key error: (NSError **) error
{
    NSData *desEncryptedData = [self DESEncryptedDataUsingKey:key error:error];
    if (desEncryptedData)
    {
        return  [desEncryptedData base64EncodedStringWithOptions:0];
    }
    return nil;
}
- (NSString *) decryptedDesStringUsingKey: (id) key error: (NSError **) error
{
    NSData *desEncryptedData = [self decryptedDESDataUsingKey:key error:error];
    if (desEncryptedData)
    {
        return  [desEncryptedData base64EncodedStringWithOptions:0];
    }
    return nil;
}

- (NSData *) CASTEncryptedDataUsingKey: (id) key error: (NSError **) error
{
	CCCryptorStatus status = kCCSuccess;
	NSData * result = [self dataEncryptedUsingAlgorithm: kCCAlgorithmCAST
													key: key
                                                options: kCCOptionPKCS7Padding
												  error: &status];
	
	if ( result != nil )
		return ( result );
	
	if ( error != NULL )
		*error = [NSError errorWithCCCryptorStatus: status];
	
	return ( nil );
}

- (NSData *) decryptedCASTDataUsingKey: (id) key error: (NSError **) error
{
	CCCryptorStatus status = kCCSuccess;
	NSData * result = [self decryptedDataUsingAlgorithm: kCCAlgorithmCAST
													key: key
                                                options: kCCOptionPKCS7Padding
												  error: &status];
	
	if ( result != nil )
		return ( result );
	
	if ( error != NULL )
		*error = [NSError errorWithCCCryptorStatus: status];
	
	return ( nil );
}
// 解密
- (NSData *)aes256_decrypt:(NSString *)key{
    
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        
    }
    free(buffer);
    return nil;
}

@end

static void FixKeyLengths( CCAlgorithm algorithm, NSMutableData * keyData, NSMutableData * ivData )
{
	NSUInteger keyLength = [keyData length];
	switch ( algorithm )
	{
		case kCCAlgorithmAES128:
		{
			if ( keyLength <= 16 )
			{
				[keyData setLength: 16];
			}
			else if ( keyLength <= 24 )
			{
				[keyData setLength: 24];
			}
			else
			{
				[keyData setLength: 32];
			}
			
			break;
		}
			
		case kCCAlgorithmDES:
		{
			[keyData setLength: 8];
			break;
		}
			
		case kCCAlgorithm3DES:
		{
			[keyData setLength: 24];
			break;
		}
			
		case kCCAlgorithmCAST:
		{
			if ( keyLength < 5 )
			{
				[keyData setLength: 5];
			}
			else if ( keyLength > 16 )
			{
				[keyData setLength: 16];
			}
			
			break;
		}
			
		case kCCAlgorithmRC4:
		{
			if ( keyLength > 512 )
				[keyData setLength: 512];
			break;
		}
			
		default:
			break;
	}
	
	[ivData setLength: [keyData length]];
}

@implementation NSData (LowLevelCommonCryptor)

- (NSData *) _runCryptor: (CCCryptorRef) cryptor result: (CCCryptorStatus *) status
{
	size_t bufsize = CCCryptorGetOutputLength( cryptor, (size_t)[self length], true );
	void * buf = malloc( bufsize );
	size_t bufused = 0;
    size_t bytesTotal = 0;
	*status = CCCryptorUpdate( cryptor, [self bytes], (size_t)[self length], 
							  buf, bufsize, &bufused );
	if ( *status != kCCSuccess )
	{
		free( buf );
		return ( nil );
	}
    
    bytesTotal += bufused;
	
	// From Brent Royal-Gordon (Twitter: architechies):
	//  Need to update buf ptr past used bytes when calling CCCryptorFinal()
	*status = CCCryptorFinal( cryptor, buf + bufused, bufsize - bufused, &bufused );
	if ( *status != kCCSuccess )
	{
		free( buf );
		return ( nil );
	}
    
    bytesTotal += bufused;
	
	return ( [NSData dataWithBytesNoCopy: buf length: bytesTotal] );
}

- (NSData *) dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
									 key: (id) key
								   error: (CCCryptorStatus *) error
{
	return ( [self dataEncryptedUsingAlgorithm: algorithm
										   key: key
                          initializationVector: nil
									   options: 0
										 error: error] );
}

- (NSData *) dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
									 key: (id) key
                                 options: (CCOptions) options
								   error: (CCCryptorStatus *) error
{
    return ( [self dataEncryptedUsingAlgorithm: algorithm
										   key: key
                          initializationVector: nil
									   options: options
										 error: error] );
}

- (NSData *) dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
									 key: (id) key
					initializationVector: (id) iv
								 options: (CCOptions) options
								   error: (CCCryptorStatus *) error
{
	CCCryptorRef cryptor = NULL;
	CCCryptorStatus status = kCCSuccess;
	
	NSParameterAssert([key isKindOfClass: [NSData class]] || [key isKindOfClass: [NSString class]]);
	NSParameterAssert(iv == nil || [iv isKindOfClass: [NSData class]] || [iv isKindOfClass: [NSString class]]);
	
	NSMutableData * keyData, * ivData;
	if ( [key isKindOfClass: [NSData class]] )
		keyData = (NSMutableData *) [key mutableCopy];
	else
		keyData = [[key dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
	
	if ( [iv isKindOfClass: [NSString class]] )
		ivData = [[iv dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
	else
		ivData = (NSMutableData *) [iv mutableCopy];	// data or nil
	

	
	// ensure correct lengths for key and iv data, based on algorithms
	FixKeyLengths( algorithm, keyData, ivData );
	
	status = CCCryptorCreate( kCCEncrypt, algorithm, options,
							  [keyData bytes], [keyData length], [ivData bytes],
							  &cryptor );
	
	if ( status != kCCSuccess )
	{
		if ( error != NULL )
			*error = status;
		return ( nil );
	}
	
	NSData * result = [self _runCryptor: cryptor result: &status];
	if ( (result == nil) && (error != NULL) )
		*error = status;
	
	CCCryptorRelease( cryptor );
	
	return ( result );
}

- (NSData *) decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
									 key: (id) key		// data or string
								   error: (CCCryptorStatus *) error
{
	return ( [self decryptedDataUsingAlgorithm: algorithm
										   key: key
						  initializationVector: nil
									   options: 0
										 error: error] );
}

- (NSData *) decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
									 key: (id) key		// data or string
                                 options: (CCOptions) options
								   error: (CCCryptorStatus *) error
{
    return ( [self decryptedDataUsingAlgorithm: algorithm
										   key: key
						  initializationVector: nil
									   options: options
										 error: error] );
}

- (NSData *) decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
									 key: (id) key		// data or string
					initializationVector: (id) iv		// data or string
								 options: (CCOptions) options
								   error: (CCCryptorStatus *) error
{
	CCCryptorRef cryptor = NULL;
	CCCryptorStatus status = kCCSuccess;
	
	NSParameterAssert([key isKindOfClass: [NSData class]] || [key isKindOfClass: [NSString class]]);
	NSParameterAssert(iv == nil || [iv isKindOfClass: [NSData class]] || [iv isKindOfClass: [NSString class]]);
	
	NSMutableData * keyData, * ivData;
	if ( [key isKindOfClass: [NSData class]] )
		keyData = (NSMutableData *) [key mutableCopy];
	else
		keyData = [[key dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
	
	if ( [iv isKindOfClass: [NSString class]] )
		ivData = [[iv dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
	else
		ivData = (NSMutableData *) [iv mutableCopy];	// data or nil
	

	
	// ensure correct lengths for key and iv data, based on algorithms
	FixKeyLengths( algorithm, keyData, ivData );
	
	status = CCCryptorCreate( kCCDecrypt, algorithm, options,
							  [keyData bytes], [keyData length], [ivData bytes],
							  &cryptor );
	
	if ( status != kCCSuccess )
	{
		if ( error != NULL )
			*error = status;
		return ( nil );
	}
	
	NSData * result = [self _runCryptor: cryptor result: &status];
	if ( (result == nil) && (error != NULL) )
		*error = status;
	
	CCCryptorRelease( cryptor );
	
	return ( result );
}

@end
@implementation NSData (UTF8)
- (NSString *)utf8_new_String {
    NSString *string = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    if (string == nil) {
        string = [[NSString alloc] initWithData:[self UTF8Data] encoding:NSUTF8StringEncoding];
    }
    return string;
}

//              https://zh.wikipedia.org/wiki/UTF-8
//              https://www.w3.org/International/questions/qa-forms-utf-8
//
//            $field =~
//                    m/\A(
//            [\x09\x0A\x0D\x20-\x7E]            # ASCII
//            | [\xC2-\xDF][\x80-\xBF]             # non-overlong 2-byte
//            |  \xE0[\xA0-\xBF][\x80-\xBF]        # excluding overlongs
//            | [\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}  # straight 3-byte
//            |  \xED[\x80-\x9F][\x80-\xBF]        # excluding surrogates
//            |  \xF0[\x90-\xBF][\x80-\xBF]{2}     # planes 1-3
//            | [\xF1-\xF3][\x80-\xBF]{3}          # planes 4-15
//            |  \xF4[\x80-\x8F][\x80-\xBF]{2}     # plane 16
//            )*\z/x;

- (NSData *)UTF8Data {
    //保存结果
    NSMutableData *resData = [[NSMutableData alloc] initWithCapacity:self.length];
    
    NSData *replacement = [@"�" dataUsingEncoding:NSUTF8StringEncoding];
    
    uint64_t index = 0;
    const uint8_t *bytes = self.bytes;
    
    long dataLength = (long) self.length;
    
    while (index < dataLength) {
        uint8_t len = 0;
        uint8_t firstChar = bytes[index];
        
        // 1个字节
        if ((firstChar & 0x80) == 0 && (firstChar == 0x09 || firstChar == 0x0A || firstChar == 0x0D || (0x20 <= firstChar && firstChar <= 0x7E))) {
            len = 1;
        }
        // 2字节
        else if ((firstChar & 0xE0) == 0xC0 && (0xC2 <= firstChar && firstChar <= 0xDF)) {
            if (index + 1 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                if (0x80 <= secondChar && secondChar <= 0xBF) {
                    len = 2;
                }
            }
        }
        // 3字节
        else if ((firstChar & 0xF0) == 0xE0) {
            if (index + 2 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                uint8_t thirdChar = bytes[index + 2];
                
                if (firstChar == 0xE0 && (0xA0 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                } else if (((0xE1 <= firstChar && firstChar <= 0xEC) || firstChar == 0xEE || firstChar == 0xEF) && (0x80 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                } else if (firstChar == 0xED && (0x80 <= secondChar && secondChar <= 0x9F) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                }
            }
        }
        // 4字节
        else if ((firstChar & 0xF8) == 0xF0) {
            if (index + 3 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                uint8_t thirdChar = bytes[index + 2];
                uint8_t fourthChar = bytes[index + 3];
                
                if (firstChar == 0xF0) {
                    if ((0x90 <= secondChar & secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                } else if ((0xF1 <= firstChar && firstChar <= 0xF3)) {
                    if ((0x80 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                } else if (firstChar == 0xF3) {
                    if ((0x80 <= secondChar && secondChar <= 0x8F) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                }
            }
        }
        // 5个字节
        else if ((firstChar & 0xFC) == 0xF8) {
            len = 0;
        }
        // 6个字节
        else if ((firstChar & 0xFE) == 0xFC) {
            len = 0;
        }
        
        if (len == 0) {
            index++;
            [resData appendData:replacement];
        } else {
            [resData appendBytes:bytes + index length:len];
            index += len;
        }
    }
    
    return resData;
}
@end
@implementation NSData (CommonHMAC)

- (NSData *) HMACWithAlgorithm: (CCHmacAlgorithm) algorithm
{
	return ( [self HMACWithAlgorithm: algorithm key: nil] );
}

- (NSData *) HMACWithAlgorithm: (CCHmacAlgorithm) algorithm key: (id) key
{
	NSParameterAssert(key == nil || [key isKindOfClass: [NSData class]] || [key isKindOfClass: [NSString class]]);
	
	NSData * keyData = nil;
	if ( [key isKindOfClass: [NSString class]] )
		keyData = [key dataUsingEncoding: NSUTF8StringEncoding];
	else
		keyData = (NSData *) key;
	
	// this could be either CC_SHA1_DIGEST_LENGTH or CC_MD5_DIGEST_LENGTH. SHA1 is larger.
	unsigned char buf[CC_SHA1_DIGEST_LENGTH];
	CCHmac( algorithm, [keyData bytes], [keyData length], [self bytes], [self length], buf );
	
	return ( [NSData dataWithBytes: buf length: (algorithm == kCCHmacAlgMD5 ? CC_MD5_DIGEST_LENGTH : CC_SHA1_DIGEST_LENGTH)] );
}
- (NSData *)dataByHealingGB18030Stream {
    NSUInteger length = [self length];
    if (length == 0) {
        return self;
    }
    
    static NSString * replacementCharacter = @"?";
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *replacementCharacterData = [replacementCharacter dataUsingEncoding:enc];
    
    NSMutableData *resultData = [NSMutableData dataWithCapacity:self.length];
    
    const Byte *bytes = [self bytes];
    
    static const NSUInteger bufferMaxSize = 1024;
    Byte buffer[bufferMaxSize];
    NSUInteger bufferIndex = 0;
    
    NSUInteger byteIndex = 0;
    BOOL invalidByte = NO;
    
    
#define FlushBuffer() if (bufferIndex > 0) { \
[resultData appendBytes:buffer length:bufferIndex]; \
bufferIndex = 0; \
}
#define CheckBuffer() if ((bufferIndex+5) >= bufferMaxSize) { \
[resultData appendBytes:buffer length:bufferIndex]; \
bufferIndex = 0; \
}
    
    
    while (byteIndex < length) {
        Byte byte = bytes[byteIndex];
        
        //检查第一位
        if (byte >= 0 && byte <= (Byte)0x7f) {
            //单字节文字
            CheckBuffer();
            buffer[bufferIndex++] = byte;
        } else if (byte >= (Byte)0x81 && byte <= (Byte)0xfe){
            //可能是双字节，可能是四字节
            if (byteIndex + 1 >= length) {
                //这是最后一个字节了，但是这个字节表明后面应该还有1或3个字节，那么这个字节一定是错误字节
                FlushBuffer();
                return resultData;
            }
            
            Byte byte2 = bytes[++byteIndex];
            if (byte2 >= (Byte)0x40 && byte <= (Byte)0xfe && byte != (Byte)0x7f) {
                //是双字节，并且可能合法
                Byte tuple[] = {byte, byte2};
                CFStringRef cfstr = CFStringCreateWithBytes(kCFAllocatorDefault, tuple, 2, kCFStringEncodingGB_18030_2000, false);
                if (cfstr) {
                    CFRelease(cfstr);
                    CheckBuffer();
                    buffer[bufferIndex++] = byte;
                    buffer[bufferIndex++] = byte2;
                } else {
                    //这个双字节字符不合法，但byte2可能是下一字符的第一字节
                    byteIndex -= 1;
                    invalidByte = YES;
                }
            } else if (byte2 >= (Byte)0x30 && byte2 <= (Byte)0x39) {
                //可能是四字节
                if (byteIndex + 2 >= length) {
                    FlushBuffer();
                    return resultData;
                }
                
                Byte byte3 = bytes[++byteIndex];
                
                if (byte3 >= (Byte)0x81 && byte3 <= (Byte)0xfe) {
                    // 第三位合法，判断第四位
                    
                    Byte byte4 = bytes[++byteIndex];
                    
                    if (byte4 >= (Byte)0x30 && byte4 <= (Byte)0x39) {
                        //第四位可能合法
                        Byte tuple[] = {byte, byte2, byte3, byte4};
                        CFStringRef cfstr = CFStringCreateWithBytes(kCFAllocatorDefault, tuple, 4, kCFStringEncodingGB_18030_2000, false);
                        if (cfstr) {
                            CFRelease(cfstr);
                            CheckBuffer();
                            buffer[bufferIndex++] = byte;
                            buffer[bufferIndex++] = byte2;
                            buffer[bufferIndex++] = byte3;
                            buffer[bufferIndex++] = byte4;
                        } else {
                            //这个四字节字符不合法，但是byte2可能是下一个合法字符的第一字节，回退3位
                            //并且将byte1,byte2用?替代
                            byteIndex -= 3;
                            invalidByte = YES;
                        }
                    } else {
                        //第四字节不合法
                        byteIndex -= 3;
                        invalidByte = YES;
                    }
                } else {
                    // 第三字节不合法
                    byteIndex -= 2;
                    invalidByte = YES;
                }
            } else {
                // 第二字节不是合法的第二位，但可能是下一个合法的第一位，所以回退一个byte
                invalidByte = YES;
                byteIndex -= 1;
            }
            
            if (invalidByte) {
                invalidByte = NO;
                FlushBuffer();
                [resultData appendData:replacementCharacterData];
            }
        }
        byteIndex++;
    }
    FlushBuffer();
    return resultData;
}
@end
