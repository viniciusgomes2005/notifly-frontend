import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notifly_frontend/api/api_manager.dart';
import 'package:notifly_frontend/colors.dart';
import 'package:notifly_frontend/extensions.dart';
import 'package:notifly_frontend/models/chat_model.dart';
import 'package:notifly_frontend/router/app_router.gr.dart';
import 'package:notifly_frontend/validators.dart';
import 'package:notifly_frontend/widgets/custom_dialog.dart';
import 'package:notifly_frontend/widgets/logo.dart';

class PadScaffold extends StatefulWidget {
  const PadScaffold({
    super.key,
    required this.body,
    this.title = "",
    this.subtitle = "",
    this.actions,
    this.useDarkLogo = false,
  });

  final Widget body;
  final String title;
  final String subtitle;
  final Widget? actions;
  final bool useDarkLogo;

  @override
  State<PadScaffold> createState() => _PadScaffoldState();
}

class _PadScaffoldState extends State<PadScaffold> {
  late final TextEditingController emailController;
  Future<ChatList?>? dataChat;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Hive.box("userData").get("id") ?? "";
    final Widget logoWidg = widget.useDarkLogo
        ? const DarkLogo()
        : const Logo();
    final Widget iconWdgt = IconButton(
      icon: Icon(Icons.add, color: widget.useDarkLogo ? lightPurple : lightBg),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          widget.useDarkLogo ? lightBg : lightPurple,
        ),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      onPressed: () async {
        await showPopUp(
          context,
          title: "Converse com:",
          content: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'email@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: Validator.validateEmail,
            ),
          ],
          onConfirmed: () async {
            setState(() {
              isLoading = true;
            });
            final email = emailController.text;
            final response = await ApiManager().createChat(
              user1Id: userId,
              user2Email: email,
            );
            if (response.id.isNotEmpty) {
              context.successSnackBar('Chat criado com sucesso!');
            } else {
              context.errorSnackBar('Erro ao criar o chat.');
            }
            setState(() {
              isLoading = false;
              dataChat = null;
            });
          },
        );
      },
    ).withPadding(const EdgeInsets.only(left: 8));
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 260,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 1000),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: KeyedSubtree(
                      key: ValueKey<bool>(widget.useDarkLogo),
                      child: logoWidg,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        widget.subtitle,
                        style: const TextStyle(fontSize: 12),
                      ),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 1000),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: KeyedSubtree(
                          key: ValueKey<bool>(widget.useDarkLogo),
                          child: iconWdgt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Expanded(
                      child: FutureBuilder<ChatList?>(
                        future: dataChat ??= ApiManager().getUserChats(userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: pastelPeach,
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                "Erro ao carregar chats: ${snapshot.error}",
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.chats.isEmpty) {
                            return const Center(
                              child: Text('No chat data available.'),
                            );
                          }
                          final chatList = snapshot.data!;
                          return ListView.builder(
                            itemCount: chatList.chats.length,
                            itemBuilder: (context, index) {
                              final chat = chatList.chats[index];
                              return ListTile(
                                dense: true,
                                onTap: () => context.replaceRoute(
                                  ChatRoute(chatId: chat.id),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: widget.useDarkLogo
                                        ? lightBg
                                        : lightPurple,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                title: Text('Chat ID: ${chat.id}'),
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(child: SingleChildScrollView(child: widget.body)),
          if (widget.actions != null)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: widget.actions!,
              ),
            ),
        ],
      ),
    );
  }
}
