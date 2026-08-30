import 'package:flutter/foundation.dart';

enum MessageStatus { sending, sent, delivered, read }

@immutable
class ProductInquiryData {
  final String title;
  final double price;
  final String imageUrl;
  final String? selectedSize;
  final String? selectedColor;
  final String? material;
  final String stockStatus;

  const ProductInquiryData({
    required this.title,
    required this.price,
    required this.imageUrl,
    this.selectedSize,
    this.selectedColor,
    this.material,
    this.stockStatus = 'In Stock • Ready to ship',
  });
}

@immutable
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final ProductInquiryData? productCard;
  final String? attachmentUrl;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.productCard,
    this.attachmentUrl,
    this.status = MessageStatus.read,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? text,
    DateTime? timestamp,
    bool? isMe,
    ProductInquiryData? productCard,
    String? attachmentUrl,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
      productCard: productCard ?? this.productCard,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      status: status ?? this.status,
    );
  }
}
