import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'esp_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const TabletRobotApp());
}

// ============================================================
// APP
// ============================================================

class TabletRobotApp extends StatelessWidget {
  const TabletRobotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tablet Robot',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// ANA EKRAN
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RobotDevice? _activeRobot;
  bool _connected = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _checking = true);
    final robot = await RobotService.getActiveRobot();
    final connected = robot == null ? false : await EspService.ping(robot.ip);
    if (!mounted) return;
    setState(() {
      _activeRobot = robot;
      _connected = connected;
      _checking = false;
    });
  }

  Future<void> _onConnectPressed() async {
    if (_activeRobot == null) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const RobotsScreen()));
      _refresh();
      return;
    }
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tablet Robot',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Merhaba! 👋',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Robotunu programlamaya hazır mısın?',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Robot bağlantı kartı
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: (_connected ? Colors.green : Colors.red).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _connected ? Icons.wifi : Icons.wifi_off,
                        color: _connected ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activeRobot?.name ?? 'Robot seçilmedi',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _activeRobot == null
                                ? 'Önce bir robot ekle'
                                : (_connected ? _activeRobot!.ip : 'Bağlantı yok'),
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_activeRobot != null) ...[
                      IconButton(
                        tooltip: 'Robotları yönet',
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RobotsScreen()),
                          );
                          _refresh();
                        },
                        icon: const Icon(Icons.tune),
                      ),
                    ],
                    ElevatedButton(
                      onPressed: _checking ? null : _onConnectPressed,
                      child: Text(_activeRobot == null ? 'Robot Seç' : 'Bağlan'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Ne yapmak istiyorsun?',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: MenuCard(
                        icon: Icons.code,
                        title: 'Programla',
                        subtitle: 'Bloklarla robotunu programla',
                        color: const Color(0xFF2563EB),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProgrammingScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: MenuCard(
                        icon: Icons.gamepad,
                        title: 'Kontrol Et',
                        subtitle: 'Robotu manuel olarak kontrol et',
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ControlScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: MenuCard(
                        icon: Icons.folder,
                        title: 'Projeler',
                        subtitle: 'Projelerini yönet',
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProjectsScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: MenuCard(
                        icon: Icons.settings,
                        title: 'Ayarlar',
                        subtitle: 'Uygulama ayarları',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ANA MENÜ KARTI
// ============================================================

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color,
                size: 27,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PUZZLE BLOK ÇİZİCİ (CUSTOM PAINTER) - Üstte Girdi (Oyuk), Altta Çıkıntı
// ============================================================

class PuzzleBlockPainter extends CustomPainter {
  final Color color;

  PuzzleBlockPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const double radius = 8.0;
    const double notchWidth = 24.0;
    const double notchHeight = 6.0;

    // 1. Üst kenar (Girdi / Oyuk - İçeriye doğru)
    path.moveTo(radius, 0);
    path.lineTo(size.width * 0.3, 0);
    path.cubicTo(
      size.width * 0.3, notchHeight,
      size.width * 0.3 + notchWidth, notchHeight,
      size.width * 0.3 + notchWidth, 0,
    );
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Sağ kenar
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);

    // 2. Alt kenar (Çıkıntı - Dışarıya doğru)
    path.lineTo(size.width * 0.3 + notchWidth, size.height);
    path.cubicTo(
      size.width * 0.3 + notchWidth, size.height + notchHeight,
      size.width * 0.3, size.height + notchHeight,
      size.width * 0.3, size.height,
    );
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    // Sol kenar
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    path.close();

    // Gölge efekti
    canvas.drawShadow(path, Colors.black.withOpacity(0.2), 3.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// PROGRAMLAMA EKRANI
// ============================================================

class ProgrammingScreen extends StatefulWidget {
  final String? projectId;
  final String? projectName;
  final List<RobotBlockData>? initialBlocks;

  const ProgrammingScreen({
    super.key,
    this.projectId,
    this.projectName,
    this.initialBlocks,
  });

  @override
  State<ProgrammingScreen> createState() => _ProgrammingScreenState();
}

class _ProgrammingScreenState extends State<ProgrammingScreen> {
  String selectedCategory = 'Hareket';
  bool robotConnected = false;
  RobotDevice? _activeRobot;
  bool _running = false;
  int _idCounter = 0;
  String? _projectId;
  String? _projectName;

  late List<RobotBlockData> workspaceBlocks = widget.initialBlocks ?? [];

  @override
  void initState() {
    super.initState();
    _projectId = widget.projectId;
    _projectName = widget.projectName;
    _refreshActiveRobot();
  }

  Future<void> _refreshActiveRobot() async {
    final robot = await RobotService.getActiveRobot();
    if (!mounted) return;
    setState(() => _activeRobot = robot);
    if (robot == null) return;
    final ok = await EspService.ping(robot.ip);
    if (!mounted) return;
    setState(() => robotConnected = ok);
  }

  void _showNoRobotSelected() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Önce bir robot seçmelisin (Robot Seç).')),
    );
  }

  Future<void> _saveProject() async {
    if (_projectId != null) {
      await ProjectService.updateProject(_projectId!, workspaceBlocks);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$_projectName" kaydedildi.')),
      );
      return;
    }
    final name = await _promptProjectName();
    if (name == null || name.trim().isEmpty) return;
    final project = await ProjectService.createProject(name.trim(), workspaceBlocks);
    if (!mounted) return;
    setState(() {
      _projectId = project.id;
      _projectName = project.name;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${project.name}" kaydedildi.')),
    );
  }

  Future<String?> _promptProjectName() {
    final controller = TextEditingController(text: 'Projem');
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Proje adı'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'ör. Çizgi İzleyen Robot'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  final ScrollController _workspaceScrollController = ScrollController();

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_workspaceScrollController.hasClients) return;
      _workspaceScrollController.animateTo(
        _workspaceScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _workspaceScrollController.dispose();
    super.dispose();
  }

  String _nextId() {
    _idCounter++;
    return 'block_$_idCounter';
  }

  final List<String> categories = [
    'Hareket',
    'Kontrol',
    'Döngü',
    'Olaylar',
    'Sensörler',
    'Görünüm',
    'Değişkenler',
    'Diğer',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SafeArea(
        child: Column(
          children: [
            // ÜST BAR
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2452E0), Color(0xFF3B82F6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.smart_toy, color: Color(0xFF2563EB), size: 20),
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      children: [
                        TextSpan(text: 'Robot', style: TextStyle(color: Colors.white)),
                        TextSpan(text: 'Kod', style: TextStyle(color: Color(0xFFFACC15))),
                      ],
                    ),
                  ),
                  if (_projectName != null) ...[
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        '•  $_projectName',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  const Spacer(),
                  const Text(
                    'Hayal et   •   Kodla   •   Hareket Ettir',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Icon(Icons.wifi, color: Colors.white70, size: 20),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: robotConnected ? const Color(0xFF22C55E) : Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          _activeRobot == null
                              ? 'Robot seçilmedi'
                              : (robotConnected
                                  ? '${_activeRobot!.name} Bağlı  •  ${_activeRobot!.ip}'
                                  : '${_activeRobot!.name} Bağlı değil'),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Kaydet',
                    onPressed: _saveProject,
                    icon: const Icon(Icons.save_outlined, color: Colors.white),
                  ),
                  IconButton(
                    tooltip: 'Ayarlar',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  ),
                ],
              ),
            ),

            // ANA ALAN
            Expanded(
              child: Row(
                children: [
                  // Kategoriler
                  Container(
                    width: 84,
                    color: Colors.white,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: categories.map((category) {
                        return CategoryButton(
                          title: category,
                          selected: selectedCategory == category,
                          icon: _categoryIcon(category),
                          color: _categoryColor(category),
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  // Blok Paleti
                  Container(
                    width: 200,
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8F9FB),
                      border: Border(
                        right: BorderSide(
                          color: Color(0xFFE1E4EA),
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedCategory,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _categoryColor(selectedCategory),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: _buildBlocks(),
                        ),
                      ],
                    ),
                  ),

                  // Çalışma Alanı
                  Expanded(
                    child: _buildWorkspace(),
                  ),

                  // Robot Paneli
                  Container(
                    width: 232,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        left: BorderSide(
                          color: Color(0xFFE1E4EA),
                        ),
                      ),
                    ),
                    child: _buildRobotPanel(),
                  ),
                ],
              ),
            ),

            // ALT BAR
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE1E4EA),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 15,
                    color: Colors.amber.shade600,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Küçük adımlarla büyük keşifler!',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.smart_toy_outlined, size: 13, color: Colors.grey.shade400),
                  const SizedBox(width: 5),
                  Text(
                    'RobotKod v1.0',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu özellik sonraki aşamada eklenecek.')),
    );
  }

  Future<void> _runProgram() async {
    final robot = _activeRobot;
    if (robot == null) {
      _showNoRobotSelected();
      return;
    }
    if (workspaceBlocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Çalışma alanında henüz blok yok.')),
      );
      return;
    }
    setState(() => _running = true);
    final ok = await EspService.sendProgram(robot.ip, workspaceBlocks);
    if (!mounted) return;
    setState(() {
      _running = false;
      robotConnected = ok;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Program "${robot.name}"a gönderildi.' : 'Program gönderilemedi, "${robot.name}"a ulaşılamadı.')),
    );
  }

  Future<void> _stopProgram() async {
    final robot = _activeRobot;
    if (robot == null) {
      _showNoRobotSelected();
      return;
    }
    final ok = await EspService.stop(robot.ip);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Robot durduruldu.' : '"${robot.name}"a ulaşılamadı.')),
    );
  }

  Future<void> _goToRobotSelect() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const RobotsScreen()));
    _refreshActiveRobot();
  }

  Widget _workspaceToolbarButton(IconData icon, String tooltip, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, size: 17, color: Colors.grey.shade700),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildWorkspace() {
    return DragTarget<BlockDragPayload>(
      onAcceptWithDetails: (details) {
        final payload = details.data;
        setState(() {
          payload.removeFromSource?.call();
          workspaceBlocks.add(
            payload.removeFromSource == null
                ? payload.block.copyWith(id: _nextId())
                : payload.block,
          );
        });
        _scrollToBottomSoon();
      },
      builder: (context, candidateData, rejectedData) {
        final hovering = candidateData.isNotEmpty;

        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: hovering ? const Color(0xFFEFF6FF) : const Color(0xFFFBFCFE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hovering ? const Color(0xFF2563EB) : const Color(0xFFE0E3E8),
              width: hovering ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 16,
                child: Text(
                  'ÇALIŞMA ALANI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _workspaceToolbarButton(Icons.undo, 'Geri al', _showComingSoon),
                    _workspaceToolbarButton(Icons.redo, 'Yinele', _showComingSoon),
                    _workspaceToolbarButton(
                      Icons.delete_outline,
                      'Sil',
                      () => setState(() => workspaceBlocks.clear()),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => workspaceBlocks.clear()),
                      icon: const Icon(Icons.layers_clear, size: 15),
                      label: const Text('Temizle', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                top: 42,
                child: workspaceBlocks.isEmpty
                    ? Center(child: _emptyWorkspace())
                    : SingleChildScrollView(
                        controller: _workspaceScrollController,
                        padding: const EdgeInsets.fromLTRB(20, 15, 20, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            for (int i = 0; i < workspaceBlocks.length; i++)
                              DragReorderSlot(
                                key: ValueKey(workspaceBlocks[i].id),
                                onAccept: (payload, insertBefore) {
                                  final anchorId = workspaceBlocks[i].id;
                                  if (payload.block.id == anchorId) return;
                                  setState(() {
                                    payload.removeFromSource?.call();
                                    final idx = workspaceBlocks.indexWhere((b) => b.id == anchorId);
                                    final insertAt = (idx == -1
                                            ? workspaceBlocks.length
                                            : (insertBefore ? idx : idx + 1))
                                        .clamp(0, workspaceBlocks.length);
                                    workspaceBlocks.insert(
                                      insertAt,
                                      payload.removeFromSource == null
                                          ? payload.block.copyWith(id: _nextId())
                                          : payload.block,
                                    );
                                  });
                                  _scrollToBottomSoon();
                                },
                                child: _workspaceBlock(workspaceBlocks[i], i),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _insertIntoContainer(
    RobotBlockData container,
    List<RobotBlockData> targetList,
    BlockDragPayload payload,
    String? anchorId,
    bool insertBefore,
  ) {
    if (payload.block.id == container.id) return;
    if (_isDescendant(payload.block, container.id)) return;
    setState(() {
      payload.removeFromSource?.call();
      int idx;
      if (anchorId == null) {
        idx = targetList.length;
      } else {
        final anchorIdx = targetList.indexWhere((b) => b.id == anchorId);
        idx = anchorIdx == -1 ? targetList.length : (insertBefore ? anchorIdx : anchorIdx + 1);
      }
      targetList.insert(
        idx.clamp(0, targetList.length),
        payload.removeFromSource == null ? payload.block.copyWith(id: _nextId()) : payload.block,
      );
    });
    _scrollToBottomSoon();
  }

  bool _isDescendant(RobotBlockData root, String targetId) {
    for (final child in [...root.children, ...root.elseChildren]) {
      if (child.id == targetId) return true;
      if (_isDescendant(child, targetId)) return true;
    }
    return false;
  }

  Widget _workspaceBlock(RobotBlockData block, int index) {
    return _buildChildWidget(
      block,
      onDelete: () => setState(() => workspaceBlocks.removeWhere((b) => b.id == block.id)),
    );
  }

  // Herhangi bir derinlikte (çalışma alanı, bir döngünün içi, bir döngünün
  // içindeki eğer bloğunun içi, vb.) bir bloğu tam işlevli şekilde (kapsayıcı
  // bloklar için kendi şart seçimi / tekrar sayısı / iç bırakma alanlarıyla
  // birlikte) üretir. Kapsayıcı bloklar kendi içindeki bloklar için bu
  // metodu tekrar çağırır (recursive), böylece iç içe geçiş derinliği
  // sınırsızdır ve her seviyedeki blok aynı etkileşimlere sahip olur.
  Widget _buildChildWidget(
    RobotBlockData block, {
    required VoidCallback onDelete,
    double maxWidth = 400,
  }) {
    final content = block.isContainer
        ? ContainerBlock(
            block: block,
            width: maxWidth < 400 ? maxWidth : 400,
            onChanged: () => setState(() {}),
            buildChildWidget: _buildChildWidget,
            onAddChild: (payload, anchorId, insertBefore) =>
                _insertIntoContainer(block, block.children, payload, anchorId, insertBefore),
            onDeleteChild: (childIndex) {
              setState(() {
                block.children.removeAt(childIndex);
              });
            },
            onAddElseChild: (payload, anchorId, insertBefore) =>
                _insertIntoContainer(block, block.elseChildren, payload, anchorId, insertBefore),
            onDeleteElseChild: (childIndex) {
              setState(() {
                block.elseChildren.removeAt(childIndex);
              });
            },
          )
        : SimpleRobotBlock(
            block: block,
            width: maxWidth < 370 ? maxWidth : 370,
            onChanged: () => setState(() {}),
          );

    return LongPressDraggable<BlockDragPayload>(
      key: ValueKey('drag_${block.id}'),
      data: BlockDragPayload(
        block: block,
        removeFromSource: onDelete,
      ),
      axis: Axis.vertical,
      feedback: Material(
        color: Colors.transparent,
        child: buildDragGhost(block),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: content),
      child: Dismissible(
        key: ValueKey(block.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        child: content,
      ),
    );
  }

  Widget _emptyWorkspace() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.touch_app_outlined,
          size: 48,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 12),
        Text(
          'Blokları buraya sürükle',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Döngü ve kontrol bloklarının içine\n'
          'başka bloklar ekleyebilirsin.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildRobotPanel() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Robot Önizleme',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          const SizedBox(height: 12),
          Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFDCE9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(Icons.wifi, size: 16, color: const Color(0xFF2563EB).withOpacity(0.6)),
                ),
                const Center(
                  child: Icon(Icons.smart_toy, size: 58, color: Color(0xFF2563EB)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _running ? null : _runProgram,
              icon: _running
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.play_arrow, size: 22),
              label: Text(
                _running ? 'Gönderiliyor...' : 'Programı Çalıştır',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              onPressed: _stopProgram,
              icon: const Icon(Icons.stop_circle_outlined, size: 17, color: Color(0xFFDC2626)),
              label: const Text(
                'Durdur',
                style: TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          const SizedBox(height: 14),

          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _refreshActiveRobot,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _activeRobot == null ? 'Robot seçilmedi' : _activeRobot!.name,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: robotConnected ? const Color(0xFF22C55E) : Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    robotConnected ? 'Bağlı' : 'Bağlı değil',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: robotConnected ? const Color(0xFF16A34A) : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.refresh, size: 14, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _goToRobotSelect,
                  icon: const Icon(Icons.smart_toy_outlined, size: 15),
                  label: Text(
                    _activeRobot?.name ?? 'Robot Seç',
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  icon: const Icon(Icons.wifi, size: 15),
                  label: const Text('Wi-Fi', style: TextStyle(fontSize: 10)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlocks() {
    switch (selectedCategory) {
      case 'Hareket':
        return ListView(
          children: [
            _paletteBlock('İleri git', Icons.arrow_upward, const Color(0xFF2196F3), BlockType.move, value: '1', unit: 'saniye'),
            _paletteBlock('Geri git', Icons.arrow_downward, const Color(0xFF2196F3), BlockType.move, value: '1', unit: 'saniye'),
            _paletteBlock('Sola dön', Icons.rotate_left, const Color(0xFF2196F3), BlockType.turn, value: '1', unit: 'saniye'),
            _paletteBlock('Sağa dön', Icons.rotate_right, const Color(0xFF2196F3), BlockType.turn, value: '1', unit: 'saniye'),
            _paletteBlock('Dur', Icons.stop, const Color(0xFF2563EB), BlockType.stop),
          ],
        );
      case 'Kontrol':
        return ListView(
          children: [
            _paletteBlock('Bekle', Icons.timer, const Color(0xFFF59E0B), BlockType.wait, value: '1', unit: 'saniye'),
            _paletteBlock('Eğer', Icons.alt_route, const Color(0xFFF97316), BlockType.ifBlock, container: true),
            _paletteBlock('Eğer / Değilse', Icons.call_split, const Color(0xFFF97316), BlockType.ifElse, container: true),
          ],
        );
      case 'Döngü':
        return ListView(
          children: [
            _paletteBlock('Tekrarla', Icons.repeat, const Color(0xFF22C55E), BlockType.repeat, container: true, value: '10', unit: 'kez'),
            _paletteBlock('Sürekli tekrarla', Icons.loop, const Color(0xFF16A34A), BlockType.forever, container: true),
          ],
        );
      case 'Olaylar':
        return ListView(
          children: [
            _paletteBlock('Başlat', Icons.play_arrow, const Color(0xFFFACC15), BlockType.start),
            _paletteBlock('Butona basılınca', Icons.touch_app, const Color(0xFFEAB308), BlockType.event, container: true),
            _paletteBlock('Sensör tetiklenince', Icons.sensors, const Color(0xFFEAB308), BlockType.event, container: true),
          ],
        );
      case 'Sensörler':
        return ListView(
          children: [
            _paletteBlock('Mesafe sensörü', Icons.sensors, const Color(0xFF0891B2), BlockType.sensor),
            _paletteBlock('Çizgi sensörü', Icons.linear_scale, const Color(0xFF0891B2), BlockType.sensor),
            _paletteBlock('Engel var mı?', Icons.warning_amber, const Color(0xFF0891B2), BlockType.sensor),
          ],
        );
      case 'Görünüm':
        return ListView(
          children: [
            _paletteBlock('LED Aç', Icons.lightbulb, const Color(0xFFDB2777), BlockType.led),
            _paletteBlock('LED Kapat', Icons.lightbulb_outline, const Color(0xFFDB2777), BlockType.led),
            _paletteBlock('LED Rengi', Icons.palette, const Color(0xFFDB2777), BlockType.led),
          ],
        );
      case 'Değişkenler':
        return ListView(
          children: [
            _paletteBlock('Değişken oluştur', Icons.add, const Color(0xFF64748B), BlockType.variable),
            _paletteBlock('Değişkeni ayarla', Icons.edit, const Color(0xFF64748B), BlockType.variable),
          ],
        );
      case 'Diğer':
        return ListView(
          children: [
            _paletteBlock('Ses çal', Icons.volume_up, const Color(0xFF9333EA), BlockType.sound),
            _paletteBlock('Bip sesi', Icons.music_note, const Color(0xFF9333EA), BlockType.sound),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _paletteBlock(
    String label,
    IconData icon,
    Color color,
    BlockType type, {
    bool container = false,
    String? value,
    String? unit,
  }) {
    final data = RobotBlockData(
      id: 'palette',
      type: type,
      label: label,
      icon: icon,
      color: color,
      value: value,
      unit: unit,
      children: [],
    );

    return Draggable<BlockDragPayload>(
      data: BlockDragPayload(block: data),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 190,
          child: SimpleRobotBlock(
            block: data,
            compact: true,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: PaletteBlockVisual(
          label: label,
          icon: icon,
          color: color,
          container: container,
        ),
      ),
      child: PaletteBlockVisual(
        label: label,
        icon: icon,
        color: color,
        container: container,
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Hareket': return Icons.directions_car_filled;
      case 'Kontrol': return Icons.tune;
      case 'Döngü': return Icons.loop;
      case 'Olaylar': return Icons.flash_on;
      case 'Sensörler': return Icons.sensors;
      case 'Görünüm': return Icons.palette;
      case 'Değişkenler': return Icons.data_object;
      case 'Diğer': return Icons.more_horiz;
      default: return Icons.extension;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Hareket': return const Color(0xFF2196F3);
      case 'Kontrol': return const Color(0xFFF97316);
      case 'Döngü': return const Color(0xFF22C55E);
      case 'Olaylar': return const Color(0xFFEAB308);
      case 'Sensörler': return const Color(0xFF0891B2);
      case 'Görünüm': return const Color(0xFFDB2777);
      case 'Değişkenler': return const Color(0xFF64748B);
      case 'Diğer': return const Color(0xFF9333EA);
      default: return Colors.blue;
    }
  }
}

// ============================================================
// BLOK TİPLERİ VE DİYALOGLAR
// ============================================================

enum BlockType {
  start, move, turn, stop, wait, repeat, forever,
  ifBlock, ifElse, event, sensor, led, variable, sound,
}

const List<Color> ledColorPalette = [
  Color(0xFFEF4444), Color(0xFFF97316), Color(0xFFFACC15),
  Color(0xFF22C55E), Color(0xFF06B6D4), Color(0xFF2563EB),
  Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFFFFFFFF),
];

String _colorToHex(Color c) => c.value.toRadixString(16).substring(2).toUpperCase();
Color _hexToColor(String hex) => Color(int.parse('FF$hex', radix: 16));

const List<String> conditionOptions = [
  'Engel var mı?', 'Mesafe < 10 cm', 'Çizgi algılandı', 'Buton basılı', 'Işık az mı?',
];

Future<String?> showNumberEditDialog(BuildContext context, {required String title, required String initialValue}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Değer gir'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              Navigator.pop(context, text.isEmpty ? initialValue : text);
            },
            child: const Text('Tamam'),
          ),
        ],
      );
    },
  );
}

Future<String?> showColorPickerDialog(BuildContext context, {String? initialHex}) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('LED rengini seç'),
        content: Wrap(
          spacing: 12, runSpacing: 12,
          children: ledColorPalette.map((color) {
            final hex = _colorToHex(color);
            final selected = hex == initialHex;
            return GestureDetector(
              onTap: () => Navigator.pop(context, hex),
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
                    width: selected ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
        ],
      );
    },
  );
}

Future<String?> showConditionPickerDialog(BuildContext context, {String? initialValue}) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: const Text('Şart seç'),
        children: conditionOptions.map((condition) {
          final selected = condition == initialValue;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, condition),
            child: Row(
              children: [
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 18,
                  color: selected ? const Color(0xFFF97316) : Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(condition),
              ],
            ),
          );
        }).toList(),
      );
    },
  );
}

const List<String> variableTypes = ['Sayı', 'Metin', 'Mantıksal'];

Future<Map<String, String>?> showVariableDialog(BuildContext context, {String? initialName, String? initialType}) {
  final nameController = TextEditingController(text: initialName ?? '');
  String selectedType = initialType ?? variableTypes.first;
  return showDialog<Map<String, String>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Değişken oluştur'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Değişken adı', hintText: 'ör. hiz'),
                ),
                const SizedBox(height: 14),
                const Text('Tip', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                const SizedBox(height: 6),
                DropdownButton<String>(
                  value: selectedType,
                  isExpanded: true,
                  items: variableTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setDialogState(() => selectedType = v);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  Navigator.pop(context, {'name': name.isEmpty ? 'değişken' : name, 'type': selectedType});
                },
                child: const Text('Tamam'),
              ),
            ],
          );
        },
      );
    },
  );
}

// ============================================================
// BLOK MODELİ
// ============================================================

// Kaydedilmiş bir projeyi geri yüklerken ikonu etiketten (label) bulur.
// IconData'yı JSON'dan gelen bir koda göre dinamik üretmek, Flutter'ın
// release build'deki ikon tree-shaking adımıyla çakışıp derlemeyi
// başarısız kıldığı için, burada sabit (const) Icons.x referansları
// kullanılıyor.
IconData iconForBlockLabel(String label) {
  switch (label) {
    case 'İleri git':
      return Icons.arrow_upward;
    case 'Geri git':
      return Icons.arrow_downward;
    case 'Sola dön':
      return Icons.rotate_left;
    case 'Sağa dön':
      return Icons.rotate_right;
    case 'Dur':
      return Icons.stop;
    case 'Bekle':
      return Icons.timer;
    case 'Eğer':
      return Icons.alt_route;
    case 'Eğer / Değilse':
      return Icons.call_split;
    case 'Tekrarla':
      return Icons.repeat;
    case 'Sürekli tekrarla':
      return Icons.loop;
    case 'Başlat':
      return Icons.play_arrow;
    case 'Butona basılınca':
      return Icons.touch_app;
    case 'Sensör tetiklenince':
      return Icons.sensors;
    case 'Mesafe sensörü':
      return Icons.sensors;
    case 'Çizgi sensörü':
      return Icons.linear_scale;
    case 'Engel var mı?':
      return Icons.warning_amber;
    case 'LED Aç':
      return Icons.lightbulb;
    case 'LED Kapat':
      return Icons.lightbulb_outline;
    case 'LED Rengi':
      return Icons.palette;
    case 'Değişken oluştur':
      return Icons.add;
    case 'Değişkeni ayarla':
      return Icons.edit;
    case 'Ses çal':
      return Icons.volume_up;
    case 'Bip sesi':
      return Icons.music_note;
    default:
      return Icons.extension;
  }
}

class RobotBlockData {
  final String id;
  final BlockType type;
  final String label;
  final IconData icon;
  final Color color;

  String? value;
  String? unit;

  List<RobotBlockData> children;
  List<RobotBlockData> elseChildren;

  RobotBlockData({
    required this.id,
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    this.value,
    this.unit,
    List<RobotBlockData>? children,
    List<RobotBlockData>? elseChildren,
  })  : children = children ?? [],
        elseChildren = elseChildren ?? [];

  bool get isContainer {
    return type == BlockType.repeat ||
        type == BlockType.forever ||
        type == BlockType.ifBlock ||
        type == BlockType.ifElse ||
        type == BlockType.event;
  }

  RobotBlockData copyWith({String? id}) {
    return RobotBlockData(
      id: id ?? this.id,
      type: type,
      label: label,
      icon: icon,
      color: color,
      value: value,
      unit: unit,
      children: children.map((child) => child.copyWith(id: child.id)).toList(),
      elseChildren: elseChildren.map((child) => child.copyWith(id: child.id)).toList(),
    );
  }

  static int _loadIdCounter = 0;
  static String _nextLoadId() => 'loaded_${DateTime.now().microsecondsSinceEpoch}_${_loadIdCounter++}';

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'label': label,
        'color': color.value,
        'value': value,
        'unit': unit,
        'children': children.map((c) => c.toJson()).toList(),
        'elseChildren': elseChildren.map((c) => c.toJson()).toList(),
      };

  factory RobotBlockData.fromJson(Map<String, dynamic> json) {
    return RobotBlockData(
      id: _nextLoadId(),
      type: BlockType.values.byName(json['type'] as String),
      label: json['label'] as String,
      icon: iconForBlockLabel(json['label'] as String),
      color: Color(json['color'] as int),
      value: json['value'] as String?,
      unit: json['unit'] as String?,
      children: (json['children'] as List)
          .map((c) => RobotBlockData.fromJson(c as Map<String, dynamic>))
          .toList(),
      elseChildren: (json['elseChildren'] as List)
          .map((c) => RobotBlockData.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ============================================================
// PALET BLOĞU GÖRÜNÜMÜ
// ============================================================

class PaletteBlockVisual extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool container;

  const PaletteBlockVisual({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.container = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PuzzleBlockPainter(color: color),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (container)
              const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18)
            else
              const Icon(Icons.drag_indicator, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BASİT ÇALIŞMA BLOĞU
// ============================================================

class SimpleRobotBlock extends StatelessWidget {
  final RobotBlockData block;
  final bool compact;
  final double? width;
  final VoidCallback? onChanged;

  const SimpleRobotBlock({
    super.key,
    required this.block,
    this.compact = false,
    this.width,
    this.onChanged,
  });

  bool get _isLedColor => block.type == BlockType.led && block.label == 'LED Rengi';
  bool get _isVariableCreate => block.type == BlockType.variable && block.label == 'Değişken oluştur';

  Future<void> _handleTap(BuildContext context) async {
    if (onChanged == null) return;

    if (_isLedColor) {
      final hex = await showColorPickerDialog(context, initialHex: block.value);
      if (hex != null) {
        block.value = hex;
        onChanged!();
      }
    } else if (_isVariableCreate) {
      final result = await showVariableDialog(context, initialName: block.value, initialType: block.unit);
      if (result != null) {
        block.value = result['name'];
        block.unit = result['type'];
        onChanged!();
      }
    } else if (block.value != null) {
      final newValue = await showNumberEditDialog(context, title: block.label, initialValue: block.value!);
      if (newValue != null) {
        block.value = newValue;
        onChanged!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedWidth = width ?? (compact ? 190.0 : 370.0);

    return CustomPaint(
      painter: PuzzleBlockPainter(color: block.color),
      child: Container(
        width: resolvedWidth,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 11 : 16,
          vertical: compact ? 10 : 10,
        ),
        child: Row(
          children: [
            Icon(block.icon, color: Colors.white, size: compact ? 18 : 20),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                block.label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildTrailing(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (_isLedColor) {
      final color = block.value != null ? _hexToColor(block.value!) : null;
      return GestureDetector(
        onTap: onChanged == null ? null : () => _handleTap(context),
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: color == null ? const Icon(Icons.palette, size: 13, color: Colors.white) : null,
        ),
      );
    }

    if (_isVariableCreate) {
      return GestureDetector(
        onTap: onChanged == null ? null : () => _handleTap(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Text(
            block.value != null ? '${block.value}${block.unit != null ? " (${block.unit})" : ""}' : 'İsim gir',
            style: TextStyle(fontSize: 10, color: block.color, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (block.value == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onChanged == null ? null : () => _handleTap(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Text(
              block.value!,
              style: TextStyle(fontSize: 11, color: block.color, fontWeight: FontWeight.bold),
            ),
          ),
          if (block.unit != null) ...[
            const SizedBox(width: 5),
            Text(
              block.unit!,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// İÇ İÇE GEÇEN BLOK (Container Block)
// ============================================================

typedef ChildBlockBuilder = Widget Function(
  RobotBlockData block, {
  required VoidCallback onDelete,
  double maxWidth,
});

class ContainerBlock extends StatelessWidget {
  final RobotBlockData block;
  final double width;
  final void Function(BlockDragPayload payload, String? anchorId, bool insertBefore) onAddChild;
  final Function(int) onDeleteChild;
  final void Function(BlockDragPayload payload, String? anchorId, bool insertBefore)? onAddElseChild;
  final Function(int)? onDeleteElseChild;
  final VoidCallback onChanged;
  final ChildBlockBuilder buildChildWidget;

  const ContainerBlock({
    super.key,
    required this.block,
    required this.width,
    required this.onAddChild,
    required this.onDeleteChild,
    required this.onChanged,
    required this.buildChildWidget,
    this.onAddElseChild,
    this.onDeleteElseChild,
  });

  bool get _isIf => block.type == BlockType.ifBlock || block.type == BlockType.ifElse;

  Future<void> _pickCondition(BuildContext context) async {
    final result = await showConditionPickerDialog(context, initialValue: block.value);
    if (result != null) {
      block.value = result;
      onChanged();
    }
  }

  Future<void> _editRepeatCount(BuildContext context) async {
    final result = await showNumberEditDialog(context, title: 'Tekrar sayısı', initialValue: block.value ?? '10');
    if (result != null) {
      block.value = result;
      onChanged();
    }
  }

  Widget _dropArea({
    required List<RobotBlockData> children,
    required void Function(BlockDragPayload payload, String? anchorId, bool insertBefore) onAdd,
    required void Function(int) onDelete,
  }) {
    return DragTarget<BlockDragPayload>(
      onAcceptWithDetails: (details) {
        onAdd(details.data, null, false);
      },
      builder: (context, candidateData, rejectedData) {
        final hovering = candidateData.isNotEmpty;

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: hovering ? Colors.white.withOpacity(0.45) : Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: Colors.white.withOpacity(0.45)),
          ),
          child: children.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      'Blokları buraya bırak',
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 10),
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < children.length; i++)
                      DragReorderSlot(
                        key: ValueKey(children[i].id),
                        onAccept: (payload, insertBefore) {
                          onAdd(payload, children[i].id, insertBefore);
                        },
                        child: buildChildWidget(
                          children[i],
                          onDelete: () {
                            final childId = children[i].id;
                            final idx = children.indexWhere((b) => b.id == childId);
                            if (idx != -1) onDelete(idx);
                          },
                          maxWidth: width - 38,
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PuzzleBlockPainter(color: block.color),
      child: Container(
        width: width,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(block.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    block.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (_isIf) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _pickCondition(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.rule, size: 15, color: block.color),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          block.value ?? 'Şart seç',
                          style: TextStyle(color: block.color, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.expand_more, size: 16, color: block.color),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            if (block.type == BlockType.ifElse) ...[
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'EĞER',
                  style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ],
            _dropArea(
              children: block.children,
              onAdd: onAddChild,
              onDelete: onDeleteChild,
            ),
            if (block.type == BlockType.ifElse) ...[
              const SizedBox(height: 8),
              const Text(
                'DEĞİLSE',
                style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 4),
              _dropArea(
                children: block.elseChildren,
                onAdd: onAddElseChild ?? onAddChild,
                onDelete: onDeleteElseChild ?? onDeleteChild,
              ),
            ],
            const SizedBox(height: 5),
            if (block.type == BlockType.repeat)
              GestureDetector(
                onTap: () => _editRepeatCount(context),
                child: Row(
                  children: [
                    const Text('Tekrarla', style: TextStyle(color: Colors.white, fontSize: 10)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
                      child: Text(
                        block.value ?? '10',
                        style: TextStyle(color: block.color, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text('kez', style: TextStyle(color: Colors.white, fontSize: 10)),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, size: 11, color: Colors.white70),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// KATEGORİ BUTONU
// ============================================================

class CategoryButton extends StatelessWidget {
  final String title;
  final bool selected;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.title,
    required this.selected,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 3),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  color: selected ? color : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SÜRÜKLENEN BLOK VERİSİ
// ============================================================
//
// removeFromSource null ise paletten gelen YENİ bir bloktur.
// Dolu ise çalışma alanında zaten var olan bir bloğun taşınmasıdır;
// bırakıldığında önce eski konumundan silinir (removeFromSource),
// sonra yeni konuma eklenir.

class BlockDragPayload {
  final RobotBlockData block;
  final VoidCallback? removeFromSource;

  const BlockDragPayload({
    required this.block,
    this.removeFromSource,
  });
}

Widget buildDragGhost(RobotBlockData block) {
  return Container(
    constraints: const BoxConstraints(maxWidth: 240),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: block.color,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(block.icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            block.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// SÜRÜKLENEN BLOĞU İKİ BLOK ARASINA / BAŞA / ORTAYA BIRAKMA
// ============================================================
//
// Sarmaladığı bloğun üst yarısına bırakılırsa ondan ÖNCEYE,
// alt yarısına bırakılırsa ondan SONRAYA ekler. Bu sayede yeni
// bloklar her zaman en sona değil, bırakıldığı yere eklenir.

class DragReorderSlot extends StatefulWidget {
  final Widget child;
  final void Function(BlockDragPayload data, bool insertBefore) onAccept;

  const DragReorderSlot({
    super.key,
    required this.child,
    required this.onAccept,
  });

  @override
  State<DragReorderSlot> createState() => _DragReorderSlotState();
}

class _DragReorderSlotState extends State<DragReorderSlot> {
  final GlobalKey _childKey = GlobalKey();
  bool _hovering = false;
  bool _topHalf = true;

  bool _isTopHalf(Offset globalOffset) {
    final renderBox = _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return true;
    final local = renderBox.globalToLocal(globalOffset);
    return local.dy < renderBox.size.height / 2;
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<BlockDragPayload>(
      onMove: (details) {
        final topHalf = _isTopHalf(details.offset);
        if (!_hovering || _topHalf != topHalf) {
          setState(() {
            _hovering = true;
            _topHalf = topHalf;
          });
        }
      },
      onLeave: (_) {
        if (_hovering) setState(() => _hovering = false);
      },
      onAcceptWithDetails: (details) {
        final topHalf = _isTopHalf(details.offset);
        setState(() => _hovering = false);
        widget.onAccept(details.data, topHalf);
      },
      builder: (context, candidateData, rejectedData) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_hovering && _topHalf) _indicator(),
            KeyedSubtree(key: _childKey, child: widget.child),
            if (_hovering && !_topHalf) _indicator(),
          ],
        );
      },
    );
  }

  Widget _indicator() {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ============================================================
// PROJE KAYDETME (Cihazda yerel olarak saklanır)
// ============================================================

class SavedProject {
  final String id;
  final String name;
  final DateTime updatedAt;
  final List<RobotBlockData> blocks;

  SavedProject({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.blocks,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'updatedAt': updatedAt.toIso8601String(),
        'blocks': blocks.map((b) => b.toJson()).toList(),
      };

  factory SavedProject.fromJson(Map<String, dynamic> json) => SavedProject(
        id: json['id'] as String,
        name: json['name'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        blocks: (json['blocks'] as List)
            .map((b) => RobotBlockData.fromJson(b as Map<String, dynamic>))
            .toList(),
      );
}

class ProjectService {
  static const _storageKey = 'robot_projects_v1';

  static Future<List<SavedProject>> listProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    final projects = raw
        .map((s) => SavedProject.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
    projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return projects;
  }

  static Future<void> _writeAll(List<SavedProject> projects) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      projects.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  static Future<SavedProject> createProject(String name, List<RobotBlockData> blocks) async {
    final projects = await listProjects();
    final project = SavedProject(
      id: 'proj_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      updatedAt: DateTime.now(),
      blocks: blocks,
    );
    projects.add(project);
    await _writeAll(projects);
    return project;
  }

  static Future<void> updateProject(String id, List<RobotBlockData> blocks) async {
    final projects = await listProjects();
    final idx = projects.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    projects[idx] = SavedProject(
      id: id,
      name: projects[idx].name,
      updatedAt: DateTime.now(),
      blocks: blocks,
    );
    await _writeAll(projects);
  }

  static Future<void> deleteProject(String id) async {
    final projects = await listProjects();
    projects.removeWhere((p) => p.id == id);
    await _writeAll(projects);
  }
}

// ============================================================
// MANUEL KONTROL EKRANI
// ============================================================

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  String _lastCommand = 'Dur';
  bool _ledOn = false;
  RobotDevice? _activeRobot;
  bool _connected = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _checking = true);
    final robot = await RobotService.getActiveRobot();
    final connected = robot == null ? false : await EspService.ping(robot.ip);
    if (!mounted) return;
    setState(() {
      _activeRobot = robot;
      _connected = connected;
      _checking = false;
    });
  }

  Future<void> _sendCommand(String label, String command) async {
    setState(() => _lastCommand = label);
    final robot = _activeRobot;
    if (robot == null) {
      _showNotConnected();
      return;
    }
    await EspService.sendCommand(robot.ip, command);
  }

  void _showNotConnected() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Önce bir robot seçmelisin (Robot Seç).')),
    );
  }

  Future<void> _goToRobotSelect() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const RobotsScreen()));
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Manuel Kontrol', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: (_connected ? Colors.green : Colors.red).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_connected ? Icons.wifi : Icons.wifi_off, color: _connected ? Colors.green : Colors.red),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_activeRobot?.name ?? 'Robot seçilmedi', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(
                            _activeRobot == null ? 'Önce bir robot ekle' : (_connected ? _activeRobot!.ip : 'Bağlantı yok'),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (_activeRobot != null) ...[
                      IconButton(
                        tooltip: 'Robotları yönet',
                        onPressed: _goToRobotSelect,
                        icon: const Icon(Icons.tune),
                      ),
                    ],
                    ElevatedButton(
                      onPressed: _checking ? null : (_activeRobot == null ? _goToRobotSelect : _refresh),
                      child: Text(_activeRobot == null ? 'Robot Seç' : 'Bağlan'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: _buildDPad()),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: _buildExtras()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _sendCommand('Dur', 'stop'),
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: const Text(
                    'ACİL DURDUR',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDPad() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Son komut: $_lastCommand',
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 18),
          _dirButton(Icons.arrow_upward, 'İleri', 'forward'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dirButton(Icons.arrow_back, 'Sol', 'left', color: const Color(0xFF8B5CF6)),
              const SizedBox(width: 10),
              _dirButton(Icons.stop, 'Dur', 'stop', color: const Color(0xFFDC2626)),
              const SizedBox(width: 10),
              _dirButton(Icons.arrow_forward, 'Sağ', 'right', color: const Color(0xFF8B5CF6)),
            ],
          ),
          const SizedBox(height: 10),
          _dirButton(Icons.arrow_downward, 'Geri', 'backward'),
        ],
      ),
    );
  }

  Widget _dirButton(IconData icon, String label, String command, {Color? color}) {
    final baseColor = color ?? const Color(0xFF2563EB);
    final active = _lastCommand == label;
    return GestureDetector(
      onTapDown: (_) => _sendCommand(label, command),
      onTapUp: (_) {
        if (label != 'Dur') _sendCommand('Dur', 'stop');
      },
      onTapCancel: () {
        if (label != 'Dur') _sendCommand('Dur', 'stop');
      },
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: active ? baseColor : baseColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? Colors.white : baseColor, size: 28),
      ),
    );
  }

  Widget _buildExtras() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Ek Kontroller', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () async {
              final robot = _activeRobot;
              if (robot == null) {
                _showNotConnected();
                return;
              }
              final newState = !_ledOn;
              setState(() => _ledOn = newState);
              await EspService.sendLed(robot.ip, on: newState);
            },
            icon: Icon(_ledOn ? Icons.lightbulb : Icons.lightbulb_outline),
            label: Text(_ledOn ? 'LED Kapat' : 'LED Aç'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _ledOn ? const Color(0xFFDB2777) : const Color(0xFFF1F5F9),
              foregroundColor: _ledOn ? Colors.white : const Color(0xFF334155),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final robot = _activeRobot;
              if (robot == null) {
                _showNotConnected();
                return;
              }
              setState(() => _lastCommand = 'Buzzer');
              await EspService.sendBuzzer(robot.ip);
            },
            icon: const Icon(Icons.volume_up),
            label: const Text('Buzzer Çal'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROJELERİM EKRANI
// ============================================================

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<SavedProject> _projects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final projects = await ProjectService.listProjects();
    if (!mounted) return;
    setState(() {
      _projects = projects;
      _loading = false;
    });
  }

  Future<void> _createNew() async {
    final name = await _promptName(title: 'Yeni proje', initial: 'Yeni Proje');
    if (name == null || name.trim().isEmpty) return;
    final project = await ProjectService.createProject(name.trim(), []);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgrammingScreen(
          projectId: project.id,
          projectName: project.name,
          initialBlocks: project.blocks,
        ),
      ),
    );
    _load();
  }

  Future<void> _open(SavedProject project) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgrammingScreen(
          projectId: project.id,
          projectName: project.name,
          initialBlocks: project.blocks,
        ),
      ),
    );
    _load();
  }

  Future<void> _delete(SavedProject project) async {
    await ProjectService.deleteProject(project.id);
    _load();
  }

  Future<String?> _promptName({required String title, String? initial}) {
    final controller = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Tamam')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Projelerim', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNew,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Proje'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_open, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'Henüz kayıtlı proje yok',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
                  itemCount: _projects.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return Dismissible(
                      key: ValueKey(project.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _delete(project),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _open(project),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.smart_toy, color: Color(0xFF2563EB)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        project.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${_countBlocks(project.blocks)} blok',
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Colors.grey.shade400),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  int _countBlocks(List<RobotBlockData> blocks) {
    int count = 0;
    for (final b in blocks) {
      count++;
      count += _countBlocks(b.children);
      count += _countBlocks(b.elseChildren);
    }
    return count;
  }
}

// ============================================================
// AYARLAR EKRANI
// ============================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<RobotDevice> _robots = [];
  RobotDevice? _activeRobot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final robots = await RobotService.listRobots();
    final active = await RobotService.getActiveRobot();
    if (!mounted) return;
    setState(() {
      _robots = robots;
      _activeRobot = active;
      _loading = false;
    });
  }

  Future<void> _goToRobots() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const RobotsScreen()));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Ayarlar', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionTitle('Robot Bağlantısı'),
            _settingsCard(
              children: [
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_robots.isEmpty)
                  Text(
                    'Henüz robot eklenmedi. Her ESP8266 kartı için bir isim ve yerel ağdaki IP adresini ekleyebilirsin.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_robots.length} robot kayıtlı',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Aktif robot: ${_activeRobot?.name ?? 'seçilmedi'}'
                        '${_activeRobot != null ? ' (${_activeRobot!.ip})' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _goToRobots,
                    icon: const Icon(Icons.smart_toy_outlined),
                    label: const Text('Robotları Yönet'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _sectionTitle('Uygulama'),
            _settingsCard(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline, color: Color(0xFF2563EB)),
                  title: const Text('Sürüm'),
                  trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
      );

  Widget _settingsCard({required List<Widget> children}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      );
}

// ============================================================
// ROBOT SEÇ / YÖNET EKRANI
// ============================================================
//
// robot1, robot2 gibi isimlendirilmiş ESP8266 kartlarının adını ve
// yerel ağdaki IP adresini kaydeder, aralarından birini "aktif robot"
// olarak seçer. Programı Çalıştır / Manuel Kontrol gibi işlemler hep
// bu aktif robotun IP'sine istek atar.

class RobotsScreen extends StatefulWidget {
  const RobotsScreen({super.key});

  @override
  State<RobotsScreen> createState() => _RobotsScreenState();
}

class _RobotsScreenState extends State<RobotsScreen> {
  List<RobotDevice> _robots = [];
  String? _activeId;
  bool _loading = true;
  final Set<String> _testing = {};
  final Map<String, bool> _testResults = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final robots = await RobotService.listRobots();
    final activeId = await RobotService.getActiveRobotId();
    if (!mounted) return;
    setState(() {
      _robots = robots;
      _activeId = activeId;
      _loading = false;
    });
  }

  Future<void> _addRobot() async {
    final result = await _promptRobot(title: 'Yeni robot ekle');
    if (result == null) return;
    await RobotService.addRobot(result['name']!, result['ip']!);
    _load();
  }

  Future<void> _editRobot(RobotDevice robot) async {
    final result = await _promptRobot(
      title: 'Robotu düzenle',
      initialName: robot.name,
      initialIp: robot.ip,
    );
    if (result == null) return;
    await RobotService.updateRobot(robot.id, result['name']!, result['ip']!);
    _load();
  }

  Future<void> _deleteRobot(RobotDevice robot) async {
    await RobotService.deleteRobot(robot.id);
    _load();
  }

  Future<void> _select(RobotDevice robot) async {
    await RobotService.setActiveRobotId(robot.id);
    setState(() => _activeId = robot.id);
  }

  Future<void> _testConnection(RobotDevice robot) async {
    setState(() => _testing.add(robot.id));
    final ok = await EspService.ping(robot.ip);
    if (!mounted) return;
    setState(() {
      _testing.remove(robot.id);
      _testResults[robot.id] = ok;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? '"${robot.name}" bağlantısı başarılı.' : '"${robot.name}"a ulaşılamadı.'),
      ),
    );
  }

  Future<Map<String, String>?> _promptRobot({
    required String title,
    String? initialName,
    String? initialIp,
  }) {
    final nameController = TextEditingController(text: initialName ?? '');
    final ipController = TextEditingController(text: initialIp ?? '');
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Robot adı', hintText: 'ör. robot1'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ipController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'IP adresi',
                  hintText: 'ör. 192.168.1.101',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Vazgeç')),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final ip = sanitizeHost(ipController.text);
                if (name.isEmpty || ip.isEmpty) {
                  Navigator.pop(context);
                  return;
                }
                Navigator.pop(context, {'name': name, 'ip': ip});
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Robotlarım', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Robot ekle',
            onPressed: _addRobot,
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRobot,
        icon: const Icon(Icons.add),
        label: const Text('Robot Ekle'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _robots.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.smart_toy_outlined, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'Henüz robot eklenmedi',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ESP8266 kartının adını ve yerel IP adresini ekleyin',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
                  itemCount: _robots.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final robot = _robots[index];
                    final isActive = robot.id == _activeId;
                    final isTesting = _testing.contains(robot.id);
                    final testResult = _testResults[robot.id];

                    return Dismissible(
                      key: ValueKey(robot.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteRobot(robot),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _select(robot),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.smart_toy, color: Color(0xFF2563EB)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            robot.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          if (isActive) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2563EB).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Aktif',
                                                style: TextStyle(
                                                  color: Color(0xFF2563EB),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        robot.ip,
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                      ),
                                      if (testResult != null) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          testResult ? 'Bağlantı başarılı' : 'Bağlantı kurulamadı',
                                          style: TextStyle(
                                            color: testResult ? const Color(0xFF16A34A) : Colors.redAccent,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Bağlantıyı test et',
                                  onPressed: isTesting ? null : () => _testConnection(robot),
                                  icon: isTesting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.wifi_find, size: 20),
                                ),
                                IconButton(
                                  tooltip: 'Düzenle',
                                  onPressed: () => _editRobot(robot),
                                  icon: const Icon(Icons.edit_outlined, size: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}