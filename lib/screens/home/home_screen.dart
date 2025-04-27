import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:software_development/widgets/reusable_widget.dart';  // DeviceCard
import 'package:software_development/widgets/task_window.dart';
import 'package:software_development/widgets/task_bar.dart';
import 'package:software_development/screens/models/task_model.dart';

import 'package:software_development/widgets/profile_icon_settings.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _profileImage;

  // Scroll controllers & flags
  final _deviceScroll = ScrollController();
  bool _devLeft = false, _devRight = false;

  final _recScroll = ScrollController();
  bool _recLeft = false, _recRight = false;

  List<Map<String, dynamic>> devices = [];
  int deviceCount = 0;

  List<Map<String, dynamic>> tasks = [];    // starts empty
  final recommendations = ['Ad 1', 'Ad 2', 'Ad 3'];

  String userName = "Allen";

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _deviceScroll.addListener(_devListener);
    _recScroll.addListener(_recListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _devRight = _deviceScroll.position.maxScrollExtent > 0;
        _recRight = _recScroll.position.maxScrollExtent > 0;
      });
    });
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image');
    if (path != null && mounted) {
      setState(() => _profileImage = File(path));
    }
  }

  void _devListener() {
    setState(() {
      _devLeft = _deviceScroll.offset > 0;
      _devRight = _deviceScroll.offset < _deviceScroll.position.maxScrollExtent;
    });
  }

  void _recListener() {
    setState(() {
      _recLeft = _recScroll.offset > 0;
      _recRight = _recScroll.offset < _recScroll.position.maxScrollExtent;
    });
  }

  @override
  void dispose() {
    _deviceScroll.dispose();
    _recScroll.dispose();
    super.dispose();
  }

  void _addDevice() {
    setState(() {
      deviceCount++;
      devices.add({
        'deviceName': 'Device #$deviceCount',
        'isOnline': deviceCount % 2 == 0,
      });
    });
  }

  void _addTask(String taskType) {
    setState(() {
      tasks.add({
        'time': DateTime.now().toString(),
        'title': taskType,
        'color': Colors.blue,
        'members': ['A', 'B'],
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xF0F6F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hi $userName",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Only this now: tappable avatar + bubble menu
                  ProfileIconSettings(
                    profileImage: _profileImage,
                    userName: userName,
                  ),
                ],
              ),

              // ── SEARCH ──
              const SizedBox(height: 20),
              // ── SEARCH ──
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 25),
              // ── DEVICES ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Devices",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _addDevice,
                    icon: const Icon(Icons.add, color: Colors.deepPurple),
                    label: const Text("Add", style: TextStyle(color: Colors.deepPurple)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 130,
                child: Stack(
                  children: [
                    ListView.builder(
                      controller: _deviceScroll,
                      scrollDirection: Axis.horizontal,
                      itemCount: devices.length,
                      itemBuilder: (c, i) {
                        final d = devices[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: DeviceCard(
                            deviceName: d['deviceName'],
                            isOnline: d['isOnline'],
                          ),
                        );
                      },
                    ),
                    if (_devLeft)
                      Positioned(
                        left: 0,
                        top: 50,
                        child: _arrow(() {
                          _deviceScroll.animateTo(
                            (_deviceScroll.offset - 150).clamp(
                                0.0, _deviceScroll.position.maxScrollExtent),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }, Icons.arrow_back_ios),
                      ),
                    if (_devRight)
                      Positioned(
                        right: 0,
                        top: 50,
                        child: _arrow(() {
                          _deviceScroll.animateTo(
                            (_deviceScroll.offset + 150).clamp(
                                0.0, _deviceScroll.position.maxScrollExtent),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }, Icons.arrow_forward_ios),
                      ),
                    if (devices.isEmpty)
                      Center(
                        child: Text("No devices connected yet.",
                            style: TextStyle(color: Colors.grey.shade600)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // ── RECOMMENDED ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recommended For You",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _addDevice,
                    label: const Text("...More", style: TextStyle(color: Colors.deepPurple)),
                  ),
                ],
              ),
              SizedBox(
                height: 120,
                child: Stack(
                  children: [
                    ListView.builder(
                      controller: _recScroll,
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendations.length,
                      itemBuilder: (c, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 5), // Give space BELOW the container
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            recommendations[i],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )),
                        if (_recLeft)
                      Positioned(
                        left: 0,
                        top: 40,
                        child: _arrow(() {
                          _recScroll.animateTo(
                            (_recScroll.offset - 150).clamp(
                                0.0, _recScroll.position.maxScrollExtent),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }, Icons.arrow_back_ios),
                      ),
                    if (_recRight)
                      Positioned(
                        right: 0,
                        top: 40,
                        child: _arrow(() {
                          _recScroll.animateTo(
                            (_recScroll.offset + 150).clamp(
                                0.0, _recScroll.position.maxScrollExtent),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }, Icons.arrow_forward_ios),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // ── TASKS (now part of same scroll) ──
              const Text("My Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              if (tasks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      "You don't have any tasks yet.",
                      style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (c, i) {
                    final t = tasks[i];
                    return _buildTaskTile(
                      time: t['time'],
                      title: t['title'],
                      color: t['color'],
                      members: t['members'],
                    );
                  },
                ),

              const SizedBox(height: 80), // space for FAB
            ],
          ),
        ),
      ),

      // bottom create-new FAB
      floatingActionButton: tasks.isEmpty
          ? FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => TaskWindow(onAddTask: _addTask),
        ),
        label: const Text('Create Task'),
        icon: const Icon(Icons.add),
      )
          : FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => TaskWindow(onAddTask: _addTask),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: tasks.isEmpty
          ? FloatingActionButtonLocation.centerFloat
          : FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _arrow(VoidCallback onTap, IconData icon) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, size: 20, color: Colors.grey.shade700),
    ),
  );

  Widget _buildTaskTile({
    required String time,
    required String title,
    required Color color,
    required List<String> members,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 20),
          Expanded(
            child: Text(title,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          Row(children: members.map((m) => _buildAvatar(m)).toList()),
        ],
      ),
    );
  }

  Widget _buildAvatar(String label) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: CircleAvatar(
      radius: 12,
      backgroundColor: Colors.grey[300],
      child: Text(label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    ),
  );
}
