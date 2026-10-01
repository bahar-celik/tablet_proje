import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wifi_off,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Robotum',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Bağlantı yok',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Robot bağlantısı sonraki aşamada eklenecek.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Bağlan'),
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
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: MenuCard(
                        icon: Icons.folder,
                        title: 'Projeler',
                        subtitle: 'Projelerini yönet',
                        color: Colors.orange,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: MenuCard(
                        icon: Icons.settings,
                        title: 'Ayarlar',
                        subtitle: 'Uygulama ayarları',
                        color: Colors.purple,
                        onTap: () {},
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
  const ProgrammingScreen({super.key});

  @override
  State<ProgrammingScreen> createState() => _ProgrammingScreenState();
}

class _ProgrammingScreenState extends State<ProgrammingScreen> {
  String selectedCategory = 'Hareket';
  bool robotConnected = false;
  int _idCounter = 0;

  late List<RobotBlockData> workspaceBlocks = [];

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
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE5E7EB),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.smart_toy,
                    color: Color(0xFF2563EB),
                    size: 27,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Robot Programı',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined),
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
                    width: 76,
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
                    width: 182,
                    padding: const EdgeInsets.all(13),
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
                    Icons.info_outline,
                    size: 15,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Blokları sürükleyerek çalışma alanına ekle.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_countBlocks(workspaceBlocks)} Blok',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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

  Widget _buildWorkspace() {
    return DragTarget<RobotBlockData>(
      onAcceptWithDetails: (details) {
        setState(() {
          workspaceBlocks.add(
            details.data.copyWith(
              id: _nextId(),
            ),
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
                top: 5,
                right: 5,
                child: IconButton(
                  tooltip: 'Temizle',
                  onPressed: () {
                    setState(() {
                      workspaceBlocks.clear();
                    });
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                  ),
                  color: Colors.grey.shade500,
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
                            for (int i = 0; i < workspaceBlocks.length; i++) ...[
                              _workspaceBlock(workspaceBlocks[i], i),
                              if (i < workspaceBlocks.length - 1)
                                const SizedBox(height: 12),
                            ],
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

  Widget _workspaceBlock(RobotBlockData block, int index) {
    return Dismissible(
      key: ValueKey(block.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        setState(() {
          workspaceBlocks.removeAt(index);
        });
      },
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
      child: block.isContainer
          ? ContainerBlock(
              block: block,
              onChanged: () => setState(() {}),
              onAddChild: (child) {
                setState(() {
                  block.children.add(
                    child.copyWith(
                      id: _nextId(),
                    ),
                  );
                });
                _scrollToBottomSoon();
              },
              onDeleteChild: (childIndex) {
                setState(() {
                  block.children.removeAt(childIndex);
                });
              },
              onAddElseChild: (child) {
                setState(() {
                  block.elseChildren.add(
                    child.copyWith(
                      id: _nextId(),
                    ),
                  );
                });
                _scrollToBottomSoon();
              },
              onDeleteElseChild: (childIndex) {
                setState(() {
                  block.elseChildren.removeAt(childIndex);
                });
              },
            )
          : SimpleRobotBlock(
              block: block,
              onChanged: () => setState(() {}),
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
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (robotConnected ? Colors.green : Colors.red).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  robotConnected ? Icons.wifi : Icons.wifi_off,
                  color: robotConnected ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Robot',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      robotConnected ? '192.168.4.1' : 'Bağlı değil',
                      style: TextStyle(
                        fontSize: 10,
                        color: robotConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Container(
          width: 105,
          height: 105,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.smart_toy,
            size: 65,
            color: Color(0xFF334155),
          ),
        ),

        const SizedBox(height: 9),

        const Text(
          'Robotum',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          robotConnected ? 'Bağlantı aktif' : 'Bağlantı bekleniyor',
          style: TextStyle(
            fontSize: 11,
            color: robotConnected ? Colors.green : Colors.grey,
          ),
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.play_arrow,
              size: 23,
            ),
            label: const Text(
              'PROGRAMI ÇALIŞTIR',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
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
          height: 40,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.stop,
              size: 18,
            ),
            label: const Text(
              'Durdur',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              side: const BorderSide(
                color: Color(0xFFFCA5A5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          height: 38,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.smart_toy_outlined,
              size: 17,
            ),
            label: const Text(
              'Robot Seç',
              style: TextStyle(
                fontSize: 11,
              ),
            ),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
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

    return Draggable<RobotBlockData>(
      data: data,
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

  int _countBlocks(List<RobotBlockData> blocks) {
    int count = 0;
    for (final block in blocks) {
      count++;
      if (block.children.isNotEmpty) {
        count += _countBlocks(block.children);
      }
    }
    return count;
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
  final VoidCallback? onChanged;

  const SimpleRobotBlock({
    super.key,
    required this.block,
    this.compact = false,
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
    final width = compact ? 190.0 : 250.0;

    return CustomPaint(
      painter: PuzzleBlockPainter(color: block.color),
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 11 : 14,
          vertical: compact ? 10 : 12,
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

class ContainerBlock extends StatelessWidget {
  final RobotBlockData block;
  final Function(RobotBlockData) onAddChild;
  final Function(int) onDeleteChild;
  final Function(RobotBlockData)? onAddElseChild;
  final Function(int)? onDeleteElseChild;
  final VoidCallback onChanged;

  const ContainerBlock({
    super.key,
    required this.block,
    required this.onAddChild,
    required this.onDeleteChild,
    required this.onChanged,
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
    required void Function(RobotBlockData) onAdd,
    required void Function(int) onDelete,
  }) {
    return DragTarget<RobotBlockData>(
      onAcceptWithDetails: (details) {
        onAdd(details.data);
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
                    for (int i = 0; i < children.length; i++) ...[
                      _ChildBlock(
                        block: children[i],
                        onDelete: () => onDelete(i),
                        onChanged: onChanged,
                      ),
                      if (i < children.length - 1) const SizedBox(height: 5),
                    ],
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
        width: 285,
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
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
// İÇ BLOK
// ============================================================

class _ChildBlock extends StatelessWidget {
  final RobotBlockData block;
  final VoidCallback onDelete;
  final VoidCallback? onChanged;

  const _ChildBlock({
    required this.block,
    required this.onDelete,
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

  Widget _buildTrailing(BuildContext context) {
    if (_isLedColor) {
      final color = block.value != null ? _hexToColor(block.value!) : null;
      return GestureDetector(
        onTap: onChanged == null ? null : () => _handleTap(context),
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: color == null ? const Icon(Icons.palette, size: 10, color: Colors.white) : null,
        ),
      );
    }

    if (_isVariableCreate) {
      return GestureDetector(
        onTap: onChanged == null ? null : () => _handleTap(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
          child: Text(
            block.value != null ? '${block.value}${block.unit != null ? " (${block.unit})" : ""}' : 'İsim gir',
            style: TextStyle(color: block.color, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (block.value == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onChanged == null ? null : () => _handleTap(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
        child: Text(
          block.value!,
          style: TextStyle(color: block.color, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('${block.id}_${block.label}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        onDelete();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 18),
      ),
      child: CustomPaint(
        painter: PuzzleBlockPainter(color: block.color),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
          child: Row(
            children: [
              Icon(block.icon, color: Colors.white, size: 17),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  block.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildTranslationTrailing(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationTrailing(BuildContext context) {
    return _buildTrailing(context);
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
              Icon(icon, size: 21, color: selected ? color : Colors.grey.shade500),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected ? color : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}