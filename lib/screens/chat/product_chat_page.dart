import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trentify/l10n/app_localizations.dart';
import 'package:trentify/model/chat_message.dart';
import 'package:trentify/model/shop_profile.dart';
import 'package:trentify/provider/seller_provider.dart';
import 'package:trentify/screens/home/product_detail.dart';
import 'package:trentify/widgets/pressable_scale.dart';

class ProductChatPage extends StatefulWidget {
  final ProductDetailData product;
  final String? selectedSize;
  final String? selectedColor;
  final ShopProfile? shopProfile;

  const ProductChatPage({
    super.key,
    required this.product,
    this.selectedSize,
    this.selectedColor,
    this.shopProfile,
  });

  @override
  State<ProductChatPage> createState() => _ProductChatPageState();
}

class _ProductChatPageState extends State<ProductChatPage> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late ShopProfile _seller;
  final List<ChatMessage> _messages = [];
  bool _isSellerTyping = false;
  bool _hasSentProductCard = false;

  @override
  void initState() {
    super.initState();
    _seller = widget.shopProfile ?? SellerProvider.instance.profile;
    _initInitialMessages();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _initInitialMessages() {
    // Initial welcome message from seller
    _messages.add(
      ChatMessage(
        id: 'msg_welcome',
        senderId: _seller.id,
        senderName: _seller.name,
        senderAvatar: _seller.logoUrl,
        text: 'Hello! 👋 Welcome to ${_seller.name}. How can we assist you with the "${widget.product.title}" today?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        isMe: false,
        status: MessageStatus.read,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _sendProductInquiryCard() {
    if (_hasSentProductCard) return;
    HapticFeedback.lightImpact();

    final card = ProductInquiryData(
      title: widget.product.title,
      price: widget.product.price,
      imageUrl: widget.product.images.isNotEmpty ? widget.product.images.first : '',
      selectedSize: widget.selectedSize ?? 'S',
      selectedColor: widget.selectedColor ?? 'Default',
      material: widget.product.specs['Material'] ?? 'Premium Quality Fabric',
      stockStatus: 'In Stock (${widget.product.soldCount} sold)',
    );

    final msg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      senderName: 'You',
      text: 'Hi, I would like to inquire about this item:',
      timestamp: DateTime.now(),
      isMe: true,
      productCard: card,
      status: MessageStatus.delivered,
    );

    setState(() {
      _messages.add(msg);
      _hasSentProductCard = true;
    });
    _scrollToBottom();

    // Trigger seller acknowledgment
    _simulateSellerReply(
      'Thank you for your interest! The "${widget.product.title}" in size ${widget.selectedSize ?? "S"} and ${widget.selectedColor ?? "color"} is available and ready for immediate shipping.',
      delayMs: 1200,
    );
  }

  void _sendTextMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    HapticFeedback.lightImpact();
    _textController.clear();

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      senderName: 'You',
      text: trimmed,
      timestamp: DateTime.now(),
      isMe: true,
      status: MessageStatus.delivered,
    );

    setState(() {
      _messages.add(userMsg);
    });
    _scrollToBottom();

    _handleAutomatedSellerResponse(trimmed);
  }

  void _handleAutomatedSellerResponse(String question) {
    final q = question.toLowerCase();
    String reply = '';

    if (q.contains('stock') || q.contains('available') || q.contains('have size') || q.contains('ready')) {
      reply = 'Yes! We have "${widget.product.title}" in stock in size ${widget.selectedSize ?? "S"}. If you order today, it will be packaged and handed over to courier within 24 hours!';
    } else if (q.contains('size') || q.contains('fit') || q.contains('measurement') || q.contains('large') || q.contains('small')) {
      reply = 'For this item, it features a tailored regular fit true to size. If you prefer a relaxed or streetwear oversized silhouette, we recommend sizing up by one size!';
    } else if (q.contains('ship') || q.contains('deliver') || q.contains('fast') || q.contains('arrive')) {
      reply = 'Standard shipping takes 1–3 business days with full real-time tracking. Express same-day delivery is also available at checkout!';
    } else if (q.contains('discount') || q.contains('promo') || q.contains('voucher') || q.contains('coupon') || q.contains('deal') || q.contains('code')) {
      if (widget.product.vouchers.isNotEmpty) {
        final v = widget.product.vouchers.first;
        reply = 'Good news! You can use promo voucher code "${v.code}" at checkout for ${v.label}. (${v.details})';
      } else {
        reply = 'We currently offer free standard shipping on orders over \$150, plus 5% instant cashback with linked bank payments!';
      }
    } else if (q.contains('material') || q.contains('fabric') || q.contains('wash') || q.contains('care') || q.contains('spec')) {
      final mat = widget.product.specs['Material'] ?? 'Premium blended silk/cotton';
      final care = widget.product.specs['Care Label'] ?? 'Dry clean or gentle hand wash';
      reply = 'The material is $mat. For best longevity, we recommend: $care.';
    } else if (q.contains('return') || q.contains('refund') || q.contains('exchange')) {
      reply = '${_seller.returnPolicy} Just reach out to us if you need any adjustments.';
    } else if (q.contains('photo') || q.contains('real') || q.contains('picture') || q.contains('video')) {
      reply = 'All photos in our listing are 100% taken from authentic studio samples under natural daylight. Let us know if you would like close-ups of specific details!';
    } else {
      reply = 'Thank you for reaching out! Our team is on standby to assist you with anything regarding "${widget.product.title}". Is there any specific sizing or color detail we can double check for you?';
    }

    _simulateSellerReply(reply, delayMs: 1400);
  }

  void _simulateSellerReply(String replyText, {int delayMs = 1200}) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _isSellerTyping = true);
      _scrollToBottom();

      Future.delayed(Duration(milliseconds: delayMs), () {
        if (!mounted) return;
        final sellerMsg = ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          senderId: _seller.id,
          senderName: _seller.name,
          senderAvatar: _seller.logoUrl,
          text: replyText,
          timestamp: DateTime.now(),
          isMe: false,
          status: MessageStatus.read,
        );

        setState(() {
          _isSellerTyping = false;
          _messages.add(sellerMsg);
        });
        _scrollToBottom();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final scaffoldBg = isDark ? const Color(0xFF0D1117) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundImage: NetworkImage(_seller.logoUrl),
                  backgroundColor: borderColor,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: cardBg, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _seller.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF3B82F6)),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Online • Replies in minutes',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.phone, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showStoreInfoSheet(context, cardBg, textPrimary, textSecondary, borderColor, primaryColor);
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.info_circle, size: 22),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showStoreInfoSheet(context, cardBg, textPrimary, textSecondary, borderColor, primaryColor);
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Pinned Product Summary Bar
          _buildPinnedProductBanner(context, isDark, primaryColor, cardBg, borderColor, textPrimary, textSecondary),

          // Message stream
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isSellerTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isSellerTyping) {
                  return _buildTypingIndicator(cardBg, borderColor, textSecondary);
                }
                final msg = _messages[index];
                return _buildMessageBubble(msg, isDark, primaryColor, cardBg, borderColor, textPrimary, textSecondary);
              },
            ),
          ),

          // Quick Question Suggestion Chips
          _buildQuickSuggestionsBar(isDark, cardBg, borderColor, textPrimary, primaryColor),

          // Bottom Input Bar
          _buildInputBar(context, isDark, primaryColor, cardBg, borderColor, textPrimary, textSecondary),
        ],
      ),
    );
  }

  Widget _buildPinnedProductBanner(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final firstImage = widget.product.images.isNotEmpty ? widget.product.images.first : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              firstImage,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 48,
                height: 48,
                color: borderColor,
                child: const Icon(CupertinoIcons.photo, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.product.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '\$${widget.product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Size: ${widget.selectedSize ?? "S"} • ${widget.selectedColor ?? "Black"}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PressableScale(
            onTap: _sendProductInquiryCard,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _hasSentProductCard ? Colors.transparent : primaryColor,
                border: Border.all(
                  color: _hasSentProductCard ? borderColor : primaryColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _hasSentProductCard ? 'Inquired' : 'Send Item',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _hasSentProductCard ? textSecondary : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestionsBar(
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color primaryColor,
  ) {
    final suggestions = [
      '📦 Is size ${widget.selectedSize ?? "S"} in stock?',
      '📏 Sizing advice for this item?',
      '🚚 How fast is standard delivery?',
      '🏷️ Are there voucher discounts?',
      '🧵 What is the fabric material?',
    ];

    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = suggestions[index];
          // Strip emoji for sending
          final cleanText = prompt.replaceFirst(RegExp(r'^[^\w\s]+\s*'), '');

          return PressableScale(
            onTap: () {
              if (!_hasSentProductCard) {
                _sendProductInquiryCard();
              }
              _sendTextMessage(cleanText);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F242C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  prompt,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(
    ChatMessage msg,
    bool isDark,
    Color primaryColor,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isMe = msg.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(_seller.logoUrl),
              backgroundColor: borderColor,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Product Inquiry Card if attached
                if (msg.productCard != null) ...[
                  _buildProductMessageCard(msg.productCard!, isDark, primaryColor, cardBg, borderColor, textPrimary, textSecondary),
                  const SizedBox(height: 6),
                ],

                // Text Bubble
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(
                    color: isMe ? primaryColor : (isDark ? const Color(0xFF1E2633) : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    border: Border.all(
                      color: isMe ? Colors.transparent : borderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: isMe ? Colors.white : textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(msg.timestamp),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isMe ? Colors.white.withValues(alpha: 0.75) : textSecondary,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.done_all_rounded,
                              size: 13,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductMessageCard(
    ProductInquiryData card,
    bool isDark,
    Color primaryColor,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  card.imageUrl,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 58,
                    height: 58,
                    color: borderColor,
                    child: const Icon(CupertinoIcons.photo),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${card.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: borderColor),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Variant: ${card.selectedSize ?? "S"} / ${card.selectedColor ?? "Default"}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
              Text(
                card.stockStatus,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(Color cardBg, Color borderColor, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage(_seller.logoUrl),
            backgroundColor: borderColor,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(delay: 0),
                const SizedBox(width: 4),
                _TypingDot(delay: 200),
                const SizedBox(width: 4),
                _TypingDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.plus_circle_fill, size: 26),
              color: primaryColor,
              onPressed: () {
                HapticFeedback.lightImpact();
                _showAttachmentModal(context, cardBg, textPrimary, textSecondary, borderColor, primaryColor);
              },
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  style: TextStyle(fontSize: 14, color: textPrimary),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (val) => _sendTextMessage(val),
                  decoration: InputDecoration(
                    hintText: context.tr('ask_seller_placeholder'),
                    hintStyle: TextStyle(fontSize: 13, color: textSecondary),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            PressableScale(
              onTap: () => _sendTextMessage(_textController.text),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(CupertinoIcons.paperplane_fill, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentModal(
    BuildContext context,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
    Color primaryColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(CupertinoIcons.photo, color: primaryColor),
                ),
                title: Text('Send Photo from Gallery', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary)),
                subtitle: Text('Attach screenshots or reference fit images', style: TextStyle(fontSize: 12, color: textSecondary)),
                onTap: () {
                  Navigator.pop(ctx);
                  _sendTextMessage('[Attached Photo: fitting_sample.jpg]');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.camera, color: Color(0xFF10B981)),
                ),
                title: Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary)),
                subtitle: Text('Snap a picture in real-time', style: TextStyle(fontSize: 12, color: textSecondary)),
                onTap: () {
                  Navigator.pop(ctx);
                  _sendTextMessage('[Attached Camera Photo]');
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.doc_text, color: Color(0xFF8B5CF6)),
                ),
                title: Text('Send Size / Spec Inquiry', style: TextStyle(fontWeight: FontWeight.w700, color: textPrimary)),
                subtitle: Text('Send exact product specifications for confirmation', style: TextStyle(fontSize: 12, color: textSecondary)),
                onTap: () {
                  Navigator.pop(ctx);
                  _sendProductInquiryCard();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStoreInfoSheet(
    BuildContext context,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
    Color primaryColor,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage(_seller.logoUrl),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _seller.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded, size: 18, color: Color(0xFF3B82F6)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _seller.handle,
                style: TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Text(
                _seller.bio,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: textPrimary, height: 1.4),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatPill('Rating', '${_seller.rating} ★', textPrimary, textSecondary),
                  _buildStatPill('Response', '99% (<5m)', textPrimary, textSecondary),
                  _buildStatPill('Followers', '${_seller.followerCount}', textPrimary, textSecondary),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color textPrimary, Color textSecondary) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
