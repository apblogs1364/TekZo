import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/admin_bottom_navigation_bar.dart';

class AdminCustomerCareScreen extends StatefulWidget {
  final String customerName;
  final String customerId;
  final Color avatarColor;
  final String avatarInitials;

  const AdminCustomerCareScreen({
    Key? key,
    this.customerName = 'Arjun Sharma',
    this.customerId = '#4582',
    this.avatarColor = const Color(0xFF5B8EA6),
    this.avatarInitials = 'AS',
  }) : super(key: key);

  @override
  State<AdminCustomerCareScreen> createState() =>
      _AdminCustomerCareScreenState();
}

class _AdminCustomerCareScreenState extends State<AdminCustomerCareScreen> {
  static const Color _accentBlue = Color(0xFF4C6FFF);
  static const Color _customerBubble = Color(0xFFF0F0F5);
  static const Color _adminBubble = Color(0xFF4C6FFF);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late List<_Message> _messages;

  final List<String> _quickReplies = [
    'Order update',
    'Payment issue',
    'Shipping delay',
    'Refund request',
    'Product query',
  ];

  @override
  void initState() {
    super.initState();
    final firstName = widget.customerName.split(' ').first;
    _messages = [
      _Message(
        text:
            'Hi, I haven\'t received my order ${widget.customerId} yet. Can you check the status for me? It\'s been 5 days since the last update.',
        sender: 'customer',
        time: '10:24 AM',
        isRead: true,
      ),
      _Message(
        text:
            'Hello $firstName! Let me look into that for you right away. One moment while I pull up your shipment details.',
        sender: 'admin',
        time: '10:26 AM',
        isRead: true,
      ),
      _Message(
        text:
            'I see the delay was due to weather conditions at the hub. It\'s back in transit now and should arrive by tomorrow.',
        sender: 'admin',
        time: '10:27 AM',
        isRead: true,
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(
        text: text,
        sender: 'admin',
        time: _currentTime(),
        isRead: false,
      ));
    });
    _messageController.clear();
    _scrollToBottom();
  }

  void _sendQuickReply(String reply) {
    setState(() {
      _messages.add(_Message(
        text: reply,
        sender: 'admin',
        time: _currentTime(),
        isRead: false,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _currentTime() {
    final now = TimeOfDay.now();
    final h = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _buildMessageList()),
                  _buildQuickReplies(),
                  _buildInputBar(),
                ],
              ),
            ),
            const AdminBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back,
                color: AppColors.black, size: 22),
          ),
          const SizedBox(width: 12),
          // Customer avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: widget.avatarColor,
            child: Text(
              widget.avatarInitials,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customerName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'CUSTOMER · ID ${widget.customerId}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _accentBlue,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: AppColors.grey500, size: 22),
        ],
      ),
    );
  }

  // ── Message List ────────────────────────────────────────────────────────────

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      itemCount: _messages.length + 1, // +1 for date divider
      itemBuilder: (context, index) {
        if (index == 0) return _buildDateDivider('TODAY');
        final msg = _messages[index - 1];
        return msg.sender == 'customer'
            ? _buildCustomerMessage(msg)
            : _buildAdminMessage(msg);
      },
    );
  }

  Widget _buildDateDivider(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.grey200)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.grey400,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.grey200)),
        ],
      ),
    );
  }

  Widget _buildCustomerMessage(_Message msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: widget.avatarColor,
            child: Text(
              widget.avatarInitials,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _customerBubble,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    msg.time,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.grey400,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAdminMessage(_Message msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(width: 40),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: const BoxDecoration(
                    color: _adminBubble,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.white,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.time,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.grey400,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (msg.isRead) ...[
                        const SizedBox(width: 3),
                        const Icon(Icons.done_all,
                            size: 13, color: _accentBlue),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Admin avatar
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: _accentBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.headset_mic_outlined,
              color: AppColors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Replies ───────────────────────────────────────────────────────────

  Widget _buildQuickReplies() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUICK REPLIES',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.grey400,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _sendQuickReply(_quickReplies[index]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(
                          color: AppColors.grey200, width: 1.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _quickReplies[index],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Input Bar ───────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Row(
        children: [
          // Attachment button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey200, width: 1.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add,
                color: AppColors.grey400, size: 20),
          ),
          const SizedBox(width: 10),
          // Text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.grey200, width: 1),
              ),
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                style: const TextStyle(
                    fontSize: 14, color: AppColors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                      color: AppColors.grey400, fontSize: 14),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: _accentBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send,
                  color: AppColors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data model ─────────────────────────────────────────────────────────────────

class _Message {
  final String text;
  final String sender; // 'customer' | 'admin'
  final String time;
  final bool isRead;

  const _Message({
    required this.text,
    required this.sender,
    required this.time,
    required this.isRead,
  });
}
