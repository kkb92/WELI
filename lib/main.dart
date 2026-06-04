import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'storage/weli_storage.dart';


class AppPalette {
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFFDBEAFE);
  static const Color accent = Color(0xFF2563EB);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF97316);
  static const Color background = Color(0xFFF4F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEFF6FF);
  static const Color border = Color(0xFFD8E0EA);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF64748B);
}

ButtonStyle appButtonStyle({
  Color backgroundColor = AppPalette.primary,
  Color foregroundColor = Colors.white,
  Color? borderColor,
  double radius = 14,
  Size minimumSize = const Size(48, 48),
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  double elevation = 0,
}) {
  return ElevatedButton.styleFrom(
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    elevation: elevation,
    shadowColor: Colors.black.withOpacity(0.16),
    minimumSize: minimumSize,
    padding: padding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: borderColor == null
          ? BorderSide.none
          : BorderSide(color: borderColor, width: 1.2),
    ),
  );
}

const List<String> presetPlayerNames = [
  'KEVIN',
  'WALTER',
  'MAXL',
  'THOMAS',
  'PINKI',
  'LUKI',
  'GOTTI',
  'JOCHEN',
];

const String currentGameStorageKey = 'weli_current_game';
const String resumableGamesStorageKey = 'weli_resumable_games';
const String gameHistoryStorageKey = 'weli_game_history';


void main() {
  runApp(MyApp());
}

class Player {
  String name;
  int points;
  bool isSelectable;
  bool isVisible;
  bool isSelected; // Für den ausgewählten Spieler im Dropdown-Menü
  bool hasRedDot; // Für den roten Punkt im GridView
  int totalPoints;

  Player(this.name, this.points, this.isSelectable, {this.isVisible = true, this.isSelected = false, this.hasRedDot = false, this.totalPoints = 0});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'points': points,
      'isSelectable': isSelectable,
      'isVisible': isVisible,
      'isSelected': isSelected,
      'hasRedDot': hasRedDot,
      'totalPoints': totalPoints,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      json['name'] as String? ?? 'SPIELER',
      json['points'] as int? ?? 15,
      json['isSelectable'] as bool? ?? true,
      isVisible: json['isVisible'] as bool? ?? true,
      isSelected: json['isSelected'] as bool? ?? false,
      hasRedDot: json['hasRedDot'] as bool? ?? false,
      totalPoints: json['totalPoints'] as int? ?? 0,
    );
  }
}

class PointsOption {
  String label;
  int value;

  PointsOption(this.label, this.value);

  static PointsOption plusOne() {
    return PointsOption('+1', 1);
  }

  static PointsOption plusTwo() {
    return PointsOption('+2', 2);
  }

  static PointsOption plusThree() {
    return PointsOption('+3', 3);
  }

  static PointsOption plusFour() {
    return PointsOption('+4', 4);
  }
}

class PointsMultiplier {
  String label;
  int multiplier;

  PointsMultiplier(this.label, this.multiplier);
}

class RoundResult {
  int roundNumber;
  Map<String, int> playerPoints;

  RoundResult(this.roundNumber, this.playerPoints);

  Map<String, dynamic> toJson() {
    return {
      'roundNumber': roundNumber,
      'playerPoints': playerPoints,
    };
  }

  factory RoundResult.fromJson(Map<String, dynamic> json) {
    return RoundResult(
      json['roundNumber'] as int? ?? 1,
      Map<String, int>.from(json['playerPoints'] as Map? ?? {}),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppPalette.background,
        primaryColor: AppPalette.primary,
        colorScheme: const ColorScheme.light(
          primary: AppPalette.primary,
          secondary: AppPalette.accent,
          surface: AppPalette.surface,
          background: AppPalette.background,
          error: AppPalette.danger,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppPalette.textPrimary,
          onBackground: AppPalette.textPrimary,
          onError: Colors.white,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppPalette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: appButtonStyle(),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppPalette.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppPalette.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppPalette.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppPalette.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppPalette.accent, width: 2),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppPalette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Player> players = [];
  int selectedPlayerCount = 3;
  bool pointsGiven = false; // Neue Variable für den Zustand der Punktevergabe
  String? selectedValue;
  bool _resumeDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _askResumeSavedGameIfAvailable();
    });
  }

  Future<void> _askResumeSavedGameIfAvailable() async {
    if (_resumeDialogShown) {
      return;
    }
    _resumeDialogShown = true;

    final savedGame = await WeliStorage.getString(currentGameStorageKey);
    if (savedGame == null || savedGame.isEmpty || !mounted) {
      await _showResumableGamesDialog();
      return;
    }

    final shouldResume = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Letztes Spiel fortsetzen?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text('Es wurde ein gespeicherter Spielstand gefunden.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Neues Spiel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: appButtonStyle(
                minimumSize: const Size(120, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text('Fortsetzen'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (shouldResume == true) {
      _openSavedGame(savedGame);
    } else if (shouldResume == false) {
      await WeliStorage.remove(currentGameStorageKey);
    }
  }

  void _openSavedGame(String savedGame) {
    final data = jsonDecode(savedGame) as Map<String, dynamic>;
    _openSavedGameData(data);
  }

  void _openSavedGameData(Map<String, dynamic> data) {
    final savedPlayers = (data['players'] as List<dynamic>? ?? [])
        .map((item) => Player.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    final savedRoundResults = (data['roundResults'] as List<dynamic>? ?? [])
        .map((item) => RoundResult.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    if (savedPlayers.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayersTablePage(
          savedPlayers,
          initialRoundNumber: data['roundNumber'] as int? ?? 1,
          initialCurrentRound: data['currentRound'] as int? ?? 1,
          initialRoundResults: savedRoundResults,
          initialSelectedDropdownIndex: data['selectedDropdownIndex'] as int?,
          initialMultiplierIndex: data['selectedMultiplierIndex'] as int? ?? 0,
          initialPaidDebtKeys: Set<String>.from(data['paidDebtKeys'] as List? ?? []),
        ),
      ),
    );
  }

  Future<void> _showResumableGamesDialog() async {
    final resumableText = await WeliStorage.getString(resumableGamesStorageKey);
    final List<dynamic> resumableGames = resumableText == null || resumableText.isEmpty
        ? []
        : jsonDecode(resumableText) as List<dynamic>;

    if (resumableGames.isEmpty || !mounted) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Fortsetzbare Spiele',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: resumableGames.asMap().entries.map((entry) {
                  final game = Map<String, dynamic>.from(entry.value as Map);
                  final date = DateTime.tryParse(game['savedAt'] as String? ?? '');
                  final dateText = date == null
                      ? '-'
                      : '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                  final playerCount = (game['players'] as List<dynamic>? ?? []).length;
                  final playerNames = (game['players'] as List<dynamic>? ?? [])
                      .map((item) => (item as Map)['name'].toString())
                      .join(', ');
                  return Card(
                    child: ListTile(
                      title: Text('$dateText · $playerCount Spieler'),
                      subtitle: Text(playerNames),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () async {
                        resumableGames.removeAt(entry.key);
                        await WeliStorage.setString(resumableGamesStorageKey, jsonEncode(resumableGames));
                        if (mounted) {
                          Navigator.pop(dialogContext);
                          _openSavedGameData(game);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SPIELERAUSWAHL'),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppPalette.background, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppPalette.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppPalette.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Wie viele Spieler?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppPalette.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Wähle die Spieleranzahl für die nächste WELI-Runde.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppPalette.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 14,
                            runSpacing: 14,
                            children: [
                              for (int i = 3; i <= 5; i++)
                                SizedBox(
                                  width: 112,
                                  height: 116,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Setze die ausgewählte Spieleranzahl
                                      setState(() {
                                        selectedPlayerCount = i;
                                      });

                                      // Lasse die Spieler benennen
                                      await _getPlayersNames(i);

                                      // Navigiere zur nächsten Seite
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PlayersTablePage(players),
                                        ),
                                      );
                                    },
                                    style: appButtonStyle(
                                      backgroundColor: selectedPlayerCount == i
                                          ? AppPalette.primary
                                          : AppPalette.surface,
                                      foregroundColor: selectedPlayerCount == i
                                          ? Colors.white
                                          : AppPalette.textPrimary,
                                      borderColor: selectedPlayerCount == i
                                          ? AppPalette.primary
                                          : AppPalette.border,
                                      radius: 22,
                                      elevation: selectedPlayerCount == i ? 8 : 0,
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$i',
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Spieler',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: selectedPlayerCount == i
                                                ? Colors.white.withOpacity(0.82)
                                                : AppPalette.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



  Future<void> _getPlayersNames(int playerCount) async {
    List<Player> selectedPlayers = [];

    for (int i = 0; i < playerCount; i++) {
      final usedNames = selectedPlayers.map((player) => player.name).toSet();
      String? playerName = await _getPlayerName(context, i + 1, usedNames);
      String finalName = playerName?.trim().toUpperCase() ?? 'SPIELER ${i + 1}';
      if (usedNames.contains(finalName)) {
        finalName = 'SPIELER ${i + 1}';
      }
      selectedPlayers.add(Player(finalName, 15, true));
    }

    final orderedPlayers = await _confirmPlayerOrder(selectedPlayers);

    setState(() {
      players = orderedPlayers ?? selectedPlayers;
    });
  }

  Future<List<Player>?> _confirmPlayerOrder(List<Player> selectedPlayers) async {
    List<Player> orderedPlayers = List<Player>.from(selectedPlayers);

    return showDialog<List<Player>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text(
                'Reihenfolge sortieren',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 320,
                child: ReorderableListView.builder(
                  itemCount: orderedPlayers.length,
                  onReorder: (oldIndex, newIndex) {
                    setDialogState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final player = orderedPlayers.removeAt(oldIndex);
                      orderedPlayers.insert(newIndex, player);
                    });
                  },
                  itemBuilder: (context, index) {
                    final player = orderedPlayers[index];
                    return ListTile(
                      key: ValueKey('${player.name}-$index'),
                      leading: CircleAvatar(
                        backgroundColor: AppPalette.primaryLight,
                        foregroundColor: AppPalette.primary,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        player.name,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      trailing: const Icon(Icons.drag_handle),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, selectedPlayers),
                  child: const Text('Überspringen'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, orderedPlayers),
                  style: appButtonStyle(
                    minimumSize: const Size(120, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Übernehmen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _getPlayerName(BuildContext context, int playerNumber, Set<String> usedNames) async {
    TextEditingController controller = TextEditingController();
    String? errorText;

    String normalize(String value) => value.trim().toUpperCase();

    void submitName(String value, StateSetter setDialogState) {
      final normalizedName = normalize(value);
      if (normalizedName.isEmpty) {
        Navigator.pop(context);
        return;
      }
      if (usedNames.contains(normalizedName)) {
        setDialogState(() {
          errorText = '$normalizedName wurde bereits ausgewählt';
        });
        return;
      }
      FocusScope.of(context).unfocus();
      Navigator.pop(context, normalizedName);
    }

    // Rückgabe des eingegebenen Spielernamens durch einen Dialog
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(
                'Spieler $playerNumber',
                style: const TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w900,
                  color: AppPalette.textPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vorgefertigte Namen',
                      style: TextStyle(
                        color: AppPalette.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: presetPlayerNames.map((name) {
                        final bool isUsed = usedNames.contains(name);
                        return ActionChip(
                          label: Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: isUsed ? AppPalette.textSecondary : AppPalette.primary,
                            ),
                          ),
                          backgroundColor: isUsed ? AppPalette.background : AppPalette.primaryLight,
                          side: const BorderSide(color: AppPalette.border),
                          onPressed: isUsed
                              ? null
                              : () {
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context, name);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: controller,
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: 'Oder eigenen Namen eingeben',
                        errorText: errorText,
                      ),
                      onSubmitted: (value) {
                        submitName(value, setDialogState);
                      },
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Schließe den Dialog, ohne einen Namen zurückzugeben
                  },
                  child: const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    submitName(controller.text, setDialogState);
                  },
                  style: appButtonStyle(
                    minimumSize: const Size(88, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

}


class PlayersTablePage extends StatefulWidget {
  final List<Player> players;
  final int initialRoundNumber;
  final int initialCurrentRound;
  final List<RoundResult> initialRoundResults;
  final int? initialSelectedDropdownIndex;
  final int initialMultiplierIndex;
  final Set<String> initialPaidDebtKeys;

  PlayersTablePage(
      this.players, {
        this.initialRoundNumber = 1,
        this.initialCurrentRound = 1,
        List<RoundResult>? initialRoundResults,
        this.initialSelectedDropdownIndex,
        this.initialMultiplierIndex = 0,
        Set<String>? initialPaidDebtKeys,
      })  : initialRoundResults = initialRoundResults ?? [],
        initialPaidDebtKeys = initialPaidDebtKeys ?? {};

  @override
  _PlayersTablePageState createState() => _PlayersTablePageState();
}

class _PlayersTablePageState extends State<PlayersTablePage> {
  Player? selectedPlayer;
  PointsOption? selectedPointsOption;
  PointsMultiplier? selectedMultiplier;
  int calculatedPoints = 0;
  int roundNumber = 1;
  List<RoundResult> roundResults = [];
  String? selectedValue;
  int currentRound = 1; // Hinzugefügte Variable für die Rundenanzeige
  Player? selectedDropdownPlayer;
  Player? selectedGridViewPlayer;
  Player? _lastTappedPlayer;
  DateTime? _lastTapTime;
  int _tapCounter = 0;
  Set<String> paidDebtKeys = {};

  List<PointsOption> pointsOptions = [
    PointsOption('-5', -5),
    PointsOption('-4', -4),
    PointsOption('-3', -3),
    PointsOption('-2', -2),
    PointsOption('-1', -1),
  ];

  List<PointsMultiplier> pointsMultipliers = [
    PointsMultiplier('x1', 1),
    PointsMultiplier('x2', 2),
    PointsMultiplier('x4', 4),
    PointsMultiplier('x8', 8),
    PointsMultiplier('x16', 16),
    PointsMultiplier('x32', 32),
    PointsMultiplier('x64', 64),
  ];

  @override
  void initState() {
    super.initState();
    roundNumber = widget.initialRoundNumber;
    currentRound = widget.initialCurrentRound;
    roundResults = List<RoundResult>.from(widget.initialRoundResults);
    paidDebtKeys = Set<String>.from(widget.initialPaidDebtKeys);

    int multiplierIndex = widget.initialMultiplierIndex;
    if (multiplierIndex < 0 || multiplierIndex >= pointsMultipliers.length) {
      multiplierIndex = 0;
    }
    selectedMultiplier = pointsMultipliers[multiplierIndex];
    selectedValue = 'x${selectedMultiplier!.multiplier}';

    if (widget.initialSelectedDropdownIndex != null &&
        widget.initialSelectedDropdownIndex! >= 0 &&
        widget.initialSelectedDropdownIndex! < widget.players.length) {
      selectedDropdownPlayer = widget.players[widget.initialSelectedDropdownIndex!];
      selectedDropdownPlayer!.isSelected = true;
      for (var player in widget.players) {
        player.hasRedDot = player == selectedDropdownPlayer;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveGameState();
    });
  }

  int _selectedDropdownPlayerIndex() {
    if (selectedDropdownPlayer == null) {
      return -1;
    }
    return widget.players.indexOf(selectedDropdownPlayer!);
  }

  Map<String, dynamic> _buildCurrentGameData() {
    return {
      'players': widget.players.map((player) => player.toJson()).toList(),
      'roundNumber': roundNumber,
      'currentRound': currentRound,
      'roundResults': roundResults.map((round) => round.toJson()).toList(),
      'selectedDropdownIndex': _selectedDropdownPlayerIndex(),
      'selectedMultiplierIndex': selectedMultiplier == null
          ? 0
          : pointsMultipliers.indexOf(selectedMultiplier!),
      'paidDebtKeys': paidDebtKeys.toList(),
      'savedAt': DateTime.now().toIso8601String(),
      'playerCount': widget.players.length,
    };
  }

  Future<void> _saveGameState() async {
    await WeliStorage.setString(currentGameStorageKey, jsonEncode(_buildCurrentGameData()));
  }

  Future<void> _clearSavedGame() async {
    await WeliStorage.remove(currentGameStorageKey);
  }

  Future<void> _saveGameAsResumable() async {
    final resumableText = await WeliStorage.getString(resumableGamesStorageKey);
    final List<dynamic> resumableGames = resumableText == null || resumableText.isEmpty
        ? []
        : jsonDecode(resumableText) as List<dynamic>;

    final data = _buildCurrentGameData();
    data['resumableId'] = DateTime.now().microsecondsSinceEpoch.toString();
    resumableGames.add(data);

    while (resumableGames.length > 50) {
      resumableGames.removeAt(0);
    }

    await WeliStorage.setString(resumableGamesStorageKey, jsonEncode(resumableGames));
  }

  double _highestDebtFromTotals(Map<String, int> totals) {
    if (totals.length < 2) {
      return 0;
    }
    final values = totals.values.toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    return ((maxValue - minValue) * 0.05).abs();
  }

  List<String> _debtKeysForTotals(Map<String, int> totals, String selectedMultiplier) {
    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final multiplier = double.tryParse(selectedMultiplier) ?? 0.05;
    final keys = <String>[];

    for (int i = 0; i < sortedEntries.length - 1; i++) {
      final firstPlayer = sortedEntries[i];
      for (int j = i + 1; j < sortedEntries.length; j++) {
        final secondPlayer = sortedEntries[j];
        final amount = ((secondPlayer.value - firstPlayer.value) * multiplier).round().abs();
        keys.add(_debtKey(selectedMultiplier, firstPlayer.key, secondPlayer.key, amount));
      }
    }

    return keys;
  }

  bool _allDebtsPaidForCurrentGame({String selectedMultiplier = '0.05'}) {
    final debtKeys = _debtKeysForTotals(calculateTotalPointsPerPlayer(), selectedMultiplier);
    if (debtKeys.isEmpty) {
      return false;
    }
    return debtKeys.every((key) => paidDebtKeys.contains(key));
  }

  Future<void> _finishGame() async {
    final allDebtsPaid = _allDebtsPaidForCurrentGame();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Spiel beenden?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            allDebtsPaid
                ? 'Alle Schulden sind erledigt. Das Spiel wird nur in die Statistik übernommen und der aktuelle Spielstand gelöscht.'
                : 'Das Spiel wird mit dem aktuellen Stand gespeichert. Du kannst es später fortsetzen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: appButtonStyle(
                backgroundColor: allDebtsPaid ? AppPalette.success : AppPalette.primary,
                minimumSize: const Size(130, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(allDebtsPaid ? 'Abschließen' : 'Speichern'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (allDebtsPaid) {
      await _saveGameToHistory('finished');
      await _clearSavedGame();
    } else {
      await _saveGameAsResumable();
      await _clearSavedGame();
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _saveGameToHistory(String reason) async {
    final historyText = await WeliStorage.getString(gameHistoryStorageKey);
    final List<dynamic> history = historyText == null || historyText.isEmpty
        ? []
        : jsonDecode(historyText) as List<dynamic>;

    final totals = calculateTotalPointsPerPlayer();
    final entry = {
      'date': DateTime.now().toIso8601String(),
      'reason': reason,
      'players': widget.players.map((player) => player.name).toList(),
      'finalTotals': totals,
      'roundCount': roundResults.length,
      'roundResults': roundResults.map((round) => round.toJson()).toList(),
      'highestDebt': _highestDebtFromTotals(totals),
      'paidDebtKeys': paidDebtKeys.toList(),
    };

    history.add(entry);
    while (history.length > 100) {
      history.removeAt(0);
    }
    await WeliStorage.setString(gameHistoryStorageKey, jsonEncode(history));
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    String confirmText = 'Bestätigen',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: appButtonStyle(
                backgroundColor: AppPalette.danger,
                minimumSize: const Size(120, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showAllPlayers() {
    setState(() {
      for (var player in widget.players) {
        player.isVisible = true;
      }
    });
    _saveGameState();
  }

  String _formatDate(String? isoText) {
    if (isoText == null) {
      return '-';
    }
    final date = DateTime.tryParse(isoText);
    if (date == null) {
      return isoText;
    }
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _debtKey(String multiplier, String fromName, String toName, int amount) {
    return '$multiplier|$fromName|$toName|$amount';
  }

  List<Widget> _buildDebtRowsFromTotals({
    required Map<String, int> totals,
    required String selectedMultiplier,
    required Set<String> paidKeys,
    required void Function(String key, bool isPaid) onChanged,
  }) {
    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final multiplier = double.tryParse(selectedMultiplier) ?? 0.05;
    final rows = <Widget>[];

    for (int i = 0; i < sortedEntries.length - 1; i++) {
      final firstPlayer = sortedEntries[i];
      rows.add(
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            '${firstPlayer.key} an',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      );

      for (int j = i + 1; j < sortedEntries.length; j++) {
        final secondPlayer = sortedEntries[j];
        final amount = ((secondPlayer.value - firstPlayer.value) * multiplier).round().abs();
        final debtKey = _debtKey(selectedMultiplier, firstPlayer.key, secondPlayer.key, amount);
        final isPaid = paidKeys.contains(debtKey);

        rows.add(
          InkWell(
            onTap: () => onChanged(debtKey, !isPaid),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      secondPlayer.key,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: isPaid ? TextDecoration.lineThrough : null,
                        color: isPaid ? AppPalette.textSecondary : AppPalette.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward),
                  const SizedBox(width: 6),
                  Text(
                    '$amount €',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: isPaid ? TextDecoration.lineThrough : null,
                      color: isPaid ? AppPalette.textSecondary : AppPalette.textPrimary,
                    ),
                  ),
                  Checkbox(
                    value: isPaid,
                    onChanged: (value) => onChanged(debtKey, value ?? false),
                    activeColor: AppPalette.success,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return rows;
  }

  Future<void> _updateHistoryPaidDebtKeys(int historyIndex, Set<String> paidKeys) async {
    final historyText = await WeliStorage.getString(gameHistoryStorageKey);
    if (historyText == null || historyText.isEmpty) {
      return;
    }
    final List<dynamic> history = jsonDecode(historyText) as List<dynamic>;
    if (historyIndex < 0 || historyIndex >= history.length) {
      return;
    }
    final item = Map<String, dynamic>.from(history[historyIndex] as Map);
    item['paidDebtKeys'] = paidKeys.toList();
    history[historyIndex] = item;
    await WeliStorage.setString(gameHistoryStorageKey, jsonEncode(history));
  }

  void _showHistoricalGameDetails(Map<String, dynamic> game, int historyIndex) {
    String selectedMultiplier = '0.05';
    final totals = Map<String, int>.from(game['finalTotals'] as Map? ?? {});
    final paidKeys = Set<String>.from(game['paidDebtKeys'] as List? ?? []);
    final roundResults = (game['roundResults'] as List<dynamic>? ?? [])
        .map((item) => RoundResult.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            void toggleDebt(String key, bool isPaid) {
              setDialogState(() {
                if (isPaid) {
                  paidKeys.add(key);
                } else {
                  paidKeys.remove(key);
                }
                game['paidDebtKeys'] = paidKeys.toList();
              });
              _updateHistoryPaidDebtKeys(historyIndex, paidKeys);
            }

            return Dialog(
              backgroundColor: Colors.white,
              child: Container(
                width: 560,
                padding: const EdgeInsets.all(18),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'SPIEL VOM ${_formatDate(game['date'] as String?)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('Runden: ${game['roundCount'] ?? roundResults.length}', style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      const Text('Endstand', style: TextStyle(fontWeight: FontWeight.w900)),
                      ...totals.entries.map((entry) => Text('${entry.key}: ${entry.value}')),
                      const SizedBox(height: 16),
                      const Text('Schulden', style: TextStyle(fontWeight: FontWeight.w900)),
                      DropdownButton<String>(
                        value: selectedMultiplier,
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() {
                            selectedMultiplier = value;
                          });
                        },
                        items: <String>['0.05', '0.10', '0.15', '0.20']
                            .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text('$value Cent'),
                        ))
                            .toList(),
                      ),
                      ..._buildDebtRowsFromTotals(
                        totals: totals,
                        selectedMultiplier: selectedMultiplier,
                        paidKeys: paidKeys,
                        onChanged: toggleDebt,
                      ),
                      const SizedBox(height: 16),
                      const Text('Rundenergebnisse', style: TextStyle(fontWeight: FontWeight.w900)),
                      ...roundResults.map((round) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Runde ${round.roundNumber}: ${round.playerPoints.entries.map((entry) => '${entry.key} ${entry.value < 0 ? 0 : entry.value}').join(', ')}',
                        ),
                      )),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: appButtonStyle(backgroundColor: AppPalette.textPrimary),
                          child: const Text('OK'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showStatisticsDialog() async {
    final historyText = await WeliStorage.getString(gameHistoryStorageKey);
    final List<dynamic> history = historyText == null || historyText.isEmpty
        ? []
        : jsonDecode(historyText) as List<dynamic>;
    final resumableText = await WeliStorage.getString(resumableGamesStorageKey);
    final List<dynamic> resumableGames = resumableText == null || resumableText.isEmpty
        ? []
        : jsonDecode(resumableText) as List<dynamic>;

    if (!mounted) {
      return;
    }

    if (history.isEmpty && resumableGames.isEmpty) {
      final currentSavedGame = await WeliStorage.getString(currentGameStorageKey);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('STATISTIK'),
            content: Text(
              currentSavedGame == null || currentSavedGame.isEmpty
                  ? 'Noch keine gespeicherten Spiele vorhanden.'
                  : 'Noch keine abgeschlossenen Spiele vorhanden. Es gibt aber ein fortsetzbares Spiel mit aktuellem Spielstand.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final Map<String, int> wins = {};
    final Map<String, int> mostPaying = {};
    final Map<String, int> roundWins = {};
    final Map<String, double> totalWonMoney = {};
    final Map<String, int> totalPoints = {};
    final Map<String, int> gameCounts = {};
    double highestDebt = 0;
    int longestGame = 0;

    for (final item in history) {
      final mapItem = Map<String, dynamic>.from(item as Map);
      final totals = Map<String, int>.from(mapItem['finalTotals'] as Map? ?? {});
      if (totals.isEmpty) {
        continue;
      }

      final sortedEntries = totals.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      final winner = sortedEntries.first.key;
      final payer = sortedEntries.last.key;
      wins[winner] = (wins[winner] ?? 0) + 1;
      mostPaying[payer] = (mostPaying[payer] ?? 0) + 1;

      for (int i = 0; i < sortedEntries.length - 1; i++) {
        final receiver = sortedEntries[i];
        for (int j = i + 1; j < sortedEntries.length; j++) {
          final payerEntry = sortedEntries[j];
          final amount = ((payerEntry.value - receiver.value) * 0.05).roundToDouble().abs();
          totalWonMoney[receiver.key] = (totalWonMoney[receiver.key] ?? 0) + amount;
        }
      }

      final savedRounds = (mapItem['roundResults'] as List<dynamic>? ?? []);
      for (final savedRound in savedRounds) {
        final round = RoundResult.fromJson(Map<String, dynamic>.from(savedRound as Map));
        final roundEntries = round.playerPoints.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));
        if (roundEntries.isNotEmpty) {
          final roundWinner = roundEntries.first.key;
          roundWins[roundWinner] = (roundWins[roundWinner] ?? 0) + 1;
        }
      }

      for (final entry in totals.entries) {
        totalPoints[entry.key] = (totalPoints[entry.key] ?? 0) + entry.value;
        gameCounts[entry.key] = (gameCounts[entry.key] ?? 0) + 1;
      }

      final debt = (mapItem['highestDebt'] as num?)?.toDouble() ?? 0;
      if (debt > highestDebt) {
        highestDebt = debt;
      }

      final rounds = mapItem['roundCount'] as int? ?? 0;
      if (rounds > longestGame) {
        longestGame = rounds;
      }
    }

    String topEntry(Map<String, int> data) {
      if (data.isEmpty) {
        return '-';
      }
      final entries = data.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return '${entries.first.key} (${entries.first.value}x)';
    }

    final averageRows = totalPoints.entries.map((entry) {
      final count = gameCounts[entry.key] ?? 1;
      final average = entry.value / count;
      return '${entry.key}: ${average.toStringAsFixed(1)} Punkte';
    }).toList()
      ..sort();

    final latestHistoryEntries = history.asMap().entries.toList().reversed.take(8).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'STATISTIK & HISTORIE',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Wer gewinnt am häufigsten: ${topEntry(wins)}'),
                  Text('Wer hat einzelne Runden am häufigsten gewonnen: ${topEntry(roundWins)}'),
                  Text('Zahlinger Manfred: ${topEntry(mostPaying)}'),
                  Text('Längstes Spiel: $longestGame Runden'),
                  const SizedBox(height: 14),
                  const Text('Durchschnittliche Punkte', style: TextStyle(fontWeight: FontWeight.w900)),
                  ...averageRows.map((row) => Text(row)),
                  const SizedBox(height: 14),
                  const Text('Fortsetzbare Spiele', style: TextStyle(fontWeight: FontWeight.w900)),
                  if (resumableGames.isEmpty)
                    const Text('-')
                  else
                    ...resumableGames.asMap().entries.map((entry) {
                      final game = Map<String, dynamic>.from(entry.value as Map);
                      final playerCount = (game['players'] as List<dynamic>? ?? []).length;
                      final names = (game['players'] as List<dynamic>? ?? [])
                          .map((item) => (item as Map)['name'].toString())
                          .join(', ');
                      return Card(
                        child: ListTile(
                          dense: true,
                          title: Text('${_formatDate(game['savedAt'] as String?)} · $playerCount Spieler'),
                          subtitle: Text(names),
                        ),
                      );
                    }),
                  const SizedBox(height: 14),
                  const Text('Verlauf', style: TextStyle(fontWeight: FontWeight.w900)),
                  ...latestHistoryEntries.map((historyEntry) {
                    final mapItem = Map<String, dynamic>.from(historyEntry.value as Map);
                    final totals = Map<String, int>.from(mapItem['finalTotals'] as Map? ?? {});
                    final sortedEntries = totals.entries.toList()
                      ..sort((a, b) => a.value.compareTo(b.value));
                    final winner = sortedEntries.isEmpty ? '-' : sortedEntries.first.key;
                    final title = '${_formatDate(mapItem['date'] as String?)} · Sieger: $winner';
                    return Card(
                      child: ListTile(
                        dense: true,
                        title: Text(title),
                        subtitle: Text('Runden: ${mapItem['roundCount'] ?? 0} · antippen für Schulden'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(context);
                          _showHistoricalGameDetails(mapItem, historyEntry.key);
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: appButtonStyle(backgroundColor: AppPalette.textPrimary),
                      child: const Text('OK'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, int> calculateTotalPointsPerPlayer() {
    Map<String, int> totalPointsPerPlayer = {};

    for (var player in widget.players) {
      totalPointsPerPlayer[player.name] = 0;
    }

    for (var roundResult in roundResults) {
      for (var entry in roundResult.playerPoints.entries) {
        // Berücksichtige nur Punkte ab 0 (+-1)
        if (entry.value >= 0) {
          totalPointsPerPlayer[entry.key] = (totalPointsPerPlayer[entry.key] ?? 0) + entry.value;
        }
      }
    }

    // Sortiere die Spieler basierend auf ihren Gesamtpunkten in aufsteigender Reihenfolge
    var sortedPlayers = totalPointsPerPlayer.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // Erstelle eine neue Map mit sortierten Einträgen
    Map<String, int> sortedTotalPointsPerPlayer = {};
    for (var entry in sortedPlayers) {
      sortedTotalPointsPerPlayer[entry.key] = entry.value;
    }

    return sortedTotalPointsPerPlayer;
  }

  void _handlePlayerCardTap(Player player) {
    final now = DateTime.now();
    final isSamePlayer = _lastTappedPlayer == player;
    final isFastEnough = _lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 700);

    if (isSamePlayer && isFastEnough) {
      _tapCounter++;
    } else {
      _tapCounter = 1;
    }

    _lastTappedPlayer = player;
    _lastTapTime = now;

    if (_tapCounter >= 3) {
      _tapCounter = 0;
      _lastTappedPlayer = null;
      _editPoints(player);
      return;
    }

    setState(() {
      selectedPlayer = selectedPlayer == player ? null : player;
    });
  }

  void _editPoints(Player player) async {
    TextEditingController controller = TextEditingController();
    controller.text = player.points.toString();
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Punktestand bearbeiten",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppPalette.textPrimary,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Neuer Punktestand"),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Schließe den Dialog
              },
              child: Text("Abbrechen"),
            ),
            ElevatedButton(
              onPressed: () {
                // Überprüfe, ob die Eingabe gültig ist
                if (controller.text.isNotEmpty) {
                  int newPoints = int.parse(controller.text);
                  setState(() {
                    player.points = newPoints;
                    // Optional: Füge hier die Aktualisierung der Gesamtpunktzahl hinzu
                  });
                }
                Navigator.of(context).pop(); // Schließe den Dialog
              },
              style: appButtonStyle(
                minimumSize: const Size(108, 44),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );
    _saveGameState();
  }

  void resetPoints() {
    setState(() {
      for (var player in widget.players) {
        player.points = 15;
      }
    });
  }

  void endRound() {
    Map<String, int> playerPoints = {};
    for (var player in widget.players) {
      playerPoints[player.name] = player.points;
    }

    RoundResult roundResult = RoundResult(roundNumber, playerPoints);
    roundResults.add(roundResult);
    roundNumber++;

    resetPoints();
    _saveGameState();
  }

  void resetRound() {
    setState(() {
      roundNumber = 1;
      roundResults.clear();
      resetPoints();

      // Multiplikator auf x1 zurücksetzen
      selectedMultiplier = pointsMultipliers[0];
      selectedValue = 'x${selectedMultiplier!.multiplier}';

      // Rundenanzahl zurücksetzen
      currentRound = 1;

      // Dropdown-Menü zurücksetzen und rote Markierung aufheben
      selectedDropdownPlayer = null;

      // Setze isSelected für alle Spieler zurück, um den roten Punkt im Dropdown-Menü zu entfernen
      // und den roten Punkt im GridView zu entfernen
      for (var player in widget.players) {
        player.isSelected = false;
        player.hasRedDot = false;
      }
    });
    _saveGameState();
  }

  void showRoundResults() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppPalette.surface,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppPalette.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.14),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'RUNDENERGEBNISSE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppPalette.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: roundResults.map((roundResult) {
                          return Container(
                            width: 164.0,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(14.0),
                            decoration: BoxDecoration(
                              color: AppPalette.background,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppPalette.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'RUNDE ${roundResult.roundNumber}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: AppPalette.primary,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: roundResult.playerPoints.entries.map((entry) {
                                    var playerName = entry.key;
                                    var playerPoints = entry.value < 0 ? 0 : entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              playerName,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                color: AppPalette.textPrimary,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            playerPoints.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: AppPalette.textPrimary,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppPalette.primaryLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Aktuelle Runde: $currentRound',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: AppPalette.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: appButtonStyle(
                        backgroundColor: AppPalette.textPrimary,
                        minimumSize: const Size(48, 50),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }





  void _applyMPlus() {
    if (selectedPlayer != null && selectedMultiplier != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(''),
            content: Text('Ist der Mula wirklich nicht durchgegangen?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyMPlusConfirmed();
                },
                child: Text('Bestätigen'),
              ),
            ],
          );
        },
      );
    }
  }

  void _applyMMinus() {
    if (selectedPlayer != null && selectedMultiplier != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Ist der Mula wirklich durchgegangen?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Abbrechen'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyMMinusConfirmed();
                },
                child: Text('Bestätigen'),
              ),
            ],
          );
        },
      );
    }
  }


  void _applyMPlusConfirmed() {
    // Überprüfen, ob kein Spieler auf 0 oder weniger Punkte fällt
    if (!widget.players.any((player) => player.points <= 0)) {
      setState(() {
        selectedPlayer!.points += 20 * selectedMultiplier!.multiplier;

        // Den restlichen Spielern -20 Punkte hinzufügen
        for (var player in widget.players) {
          if (player != selectedPlayer) {
            player.points -= 20 * selectedMultiplier!.multiplier;
            if (player.points <= 0) {
              player.points = 0;
            }
          }
        }

        // Multiplikator auf x1 zurücksetzen
        selectedMultiplier = pointsMultipliers[0];
        selectedValue = 'x${selectedMultiplier!.multiplier}';
      });

      // Überprüfen, ob ein Spieler 0 Punkte oder weniger hat
      bool anyPlayerBelowZero = widget.players.any((player) => player.points <= 0);

      // Wenn kein Spieler 0 oder weniger Punkte hat, wähle automatisch den nächsten Spieler im Uhrzeigersinn aus
      if (!anyPlayerBelowZero) {
        _automaticallySelectNextPlayer();
      } else {
        // Starte automatisch eine neue Runde, da ein Spieler auf 0 oder weniger Punkte fällt
        endRound();
        setState(() {
          currentRound++;
        });
        startNewRound(); // Neue Runde starten
      }
    } else {
      // Hier können Sie eine Benachrichtigung oder eine Meldung anzeigen, dass keine Änderungen möglich sind, da ein Spieler auf 0 oder weniger Punkte fällt.
    }
    _saveGameState();
  }

  void _applyMMinusConfirmed() {
    // Überprüfen, ob kein Spieler auf 0 oder weniger Punkte fällt
    if (!widget.players.any((player) => player.points <= 0)) {
      setState(() {
        selectedPlayer!.points -= 20 * selectedMultiplier!.multiplier;
        if (selectedPlayer!.points <= 0) {
          selectedPlayer!.points = 0;
        }

        // Den restlichen Spielern +20 Punkte hinzufügen
        for (var player in widget.players) {
          if (player != selectedPlayer) {
            player.points += 20 * selectedMultiplier!.multiplier;
            if (player.points <= 0) {
              player.points = 0;
            }
          }
        }

        // Multiplikator auf x1 zurücksetzen
        selectedMultiplier = pointsMultipliers[0];
        selectedValue = 'x${selectedMultiplier!.multiplier}';
      });

      // Überprüfen, ob ein Spieler 0 Punkte oder weniger hat
      bool anyPlayerBelowZero = widget.players.any((player) => player.points <= 0);

      // Wenn kein Spieler 0 oder weniger Punkte hat, wähle automatisch den nächsten Spieler im Uhrzeigersinn aus
      if (!anyPlayerBelowZero) {
        _automaticallySelectNextPlayer();
      } else {
        // Starte automatisch eine neue Runde, da ein Spieler auf 0 oder weniger Punkte fällt
        endRound();
        setState(() {
          currentRound++;
        });
        startNewRound(); // Neue Runde starten
      }
    } else {
      // Hier können Sie eine Benachrichtigung oder eine Meldung anzeigen, dass keine Änderungen möglich sind, da ein Spieler auf 0 oder weniger Punkte fällt.
    }
    _saveGameState();
  }








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Zurück zur Spielerauswahl',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text(
                    'Zurück zur Spielerauswahl?',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  content: const Text(
                    'Das aktuelle Spiel wird in der Historie gespeichert und du kehrst zur Spielerauswahl zurück.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Abbrechen'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                        try {
                          await _saveGameToHistory('back');
                          await _clearSavedGame();
                        } catch (_) {
                          // Auch wenn Speichern fehlschlägt, soll Zurück funktionieren.
                        }
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      style: appButtonStyle(
                        backgroundColor: AppPalette.danger,
                        minimumSize: const Size(120, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text('Zurück'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        title: const Text('W E L I'),
        actions: [
          IconButton(
            tooltip: 'Schulden',
            onPressed: () {
              _showPrizeMoneyDialog(context);
            },
            icon: const Icon(Icons.payments_outlined),
          ),
          IconButton(
            tooltip: 'Runden',
            onPressed: () {
              showRoundResults();
            },
            icon: const Icon(Icons.leaderboard_outlined),
          ),
          IconButton(
            tooltip: 'Spiel beenden',
            onPressed: () {
              _finishGame();
            },
            icon: const Icon(Icons.stop_circle_outlined),
          ),
          IconButton(
            tooltip: 'Statistik',
            onPressed: () {
              _showStatisticsDialog();
            },
            icon: const Icon(Icons.insights_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppPalette.primaryLight,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppPalette.border),
                    ),
                    child: Text(
                      'Runde $currentRound',
                      style: const TextStyle(
                        color: AppPalette.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _showAllPlayers,
                    style: appButtonStyle(
                      backgroundColor: AppPalette.surface,
                      foregroundColor: AppPalette.primary,
                      borderColor: AppPalette.border,
                      radius: 999,
                      minimumSize: const Size(58, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text(
                      'ALLE',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: selectedDropdownPlayer != null
                        ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppPalette.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppPalette.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.radio_button_checked,
                              color: AppPalette.danger, size: 16),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              selectedDropdownPlayer!.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppPalette.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppPalette.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppPalette.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Player>(
                          value: selectedDropdownPlayer,
                          hint: const Text(
                            'Startspieler wählen',
                            style: TextStyle(
                              color: AppPalette.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          isExpanded: true,
                          onChanged: (Player? newValue) {
                            setState(() {
                              // Setze den ausgewählten Spieler im Dropdown-Menü
                              selectedDropdownPlayer = newValue;

                              // Setze isSelected für alle Spieler zurück
                              for (var player in widget.players) {
                                player.isSelected = false;
                              }

                              // Setze isSelected nur für den ausgewählten Spieler
                              if (newValue != null) {
                                newValue.isSelected = true;

                                // Aktualisiere den roten Punkt für den ausgewählten Spieler im GridView
                                for (var player in widget.players) {
                                  player.hasRedDot = (player == newValue);
                                }
                              }
                            });
                            _saveGameState();
                          },
                          items: widget.players.map<DropdownMenuItem<Player>>((Player player) {
                            return DropdownMenuItem<Player>(
                              value: player,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    color: player.isSelected
                                        ? AppPalette.danger
                                        : AppPalette.textSecondary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    player.name,
                                    style: TextStyle(
                                      color: player.isSelected
                                          ? AppPalette.danger
                                          : AppPalette.textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: widget.players.length,
                itemBuilder: (context, index) {
                  Player currentPlayer = widget.players[index];
                  bool isSelected = selectedPlayer == currentPlayer;

                  if (currentPlayer.isVisible) {
                    // Extrahiere das letzte Rundenergebnis für den aktuellen Spieler
                    int lastRoundResult = roundResults.isNotEmpty ? roundResults.last.playerPoints[currentPlayer.name] ?? 0 : 0;

                    return IgnorePointer(
                      ignoring: !currentPlayer.isVisible,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () {
                          _handlePlayerCardTap(currentPlayer);
                        },
                        onLongPress: () {
                          _handleMinusButtonPress(currentPlayer);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          decoration: BoxDecoration(
                            color: isSelected ? AppPalette.surfaceAlt : AppPalette.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSelected ? AppPalette.accent : AppPalette.border,
                              width: isSelected ? 2.2 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isSelected ? 0.10 : 0.05),
                                blurRadius: isSelected ? 18 : 12,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 8,
                                left: 8,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: () {
                                    _handleLeftXButtonPress(currentPlayer);
                                  },
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: AppPalette.background,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppPalette.border),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.close,
                                        color: AppPalette.textPrimary,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: () {
                                    _handleRightXButtonPress(currentPlayer);
                                  },
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: AppPalette.danger.withOpacity(0.10),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppPalette.danger.withOpacity(0.25)),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.close,
                                        color: AppPalette.danger,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 18,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: AnimatedContainer(
                                    width: currentPlayer.hasRedDot ? 12 : 0,
                                    height: currentPlayer.hasRedDot ? 12 : 0,
                                    decoration: const BoxDecoration(
                                      color: AppPalette.danger,
                                      shape: BoxShape.circle,
                                    ),
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 42, 8, 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${currentPlayer.points}',
                                        style: const TextStyle(
                                          color: AppPalette.textPrimary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 31,
                                          height: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppPalette.background,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$lastRoundResult',
                                              style: const TextStyle(
                                                color: AppPalette.textSecondary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${calculateTotalPointsPerPlayer()[currentPlayer.name]}',
                                              style: const TextStyle(
                                                color: AppPalette.primary,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        currentPlayer.name,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: selectedDropdownPlayer == currentPlayer
                                              ? AppPalette.danger
                                              : AppPalette.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: BoxDecoration(
                color: AppPalette.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: const Border(top: BorderSide(color: AppPalette.border)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _showMultiplierMenu(context);
                          },
                          style: appButtonStyle(
                            backgroundColor: selectedMultiplier != null
                                ? AppPalette.primaryLight
                                : AppPalette.background,
                            foregroundColor: AppPalette.primary,
                            borderColor: AppPalette.border,
                          ),
                          child: Text(
                            selectedMultiplier != null
                                ? 'x${selectedMultiplier!.multiplier}'
                                : '*',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _applyMPlus();
                          },
                          style: appButtonStyle(
                            backgroundColor: selectedMultiplier != null
                                ? AppPalette.danger
                                : AppPalette.danger.withOpacity(0.65),
                          ),
                          child: const Text(
                            'M',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _applyMMinus();
                          },
                          style: appButtonStyle(
                            backgroundColor: selectedMultiplier != null
                                ? AppPalette.success
                                : AppPalette.success.withOpacity(0.65),
                          ),
                          child: const Text(
                            'M',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppPalette.background,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: ['-1', '-2', '-3', '-4', '-5'].map((label) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedPointsOption = PointsOption(label, int.parse(label));
                                });
                                _saveGameState();
                              },
                              style: appButtonStyle(
                                backgroundColor: selectedPointsOption?.label == label
                                    ? AppPalette.primary
                                    : Colors.transparent,
                                foregroundColor: selectedPointsOption?.label == label
                                    ? Colors.white
                                    : AppPalette.textPrimary,
                                radius: 14,
                                elevation: 0,
                                minimumSize: const Size(44, 44),
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedPlayer != null &&
                                selectedPointsOption != null &&
                                selectedMultiplier != null) {
                              _applyPointsToPlayer(
                                  selectedPlayer!, selectedPointsOption!.value);
                            }
                          },
                          style: appButtonStyle(
                            backgroundColor: AppPalette.primary,
                            minimumSize: const Size(48, 52),
                          ),
                          child: const Text(
                            'ÜBERNEHMEN',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 5,
                        child: ElevatedButton(
                          onPressed: () {
                            endRound();
                            setState(() {
                              currentRound++;
                              startNewRound(); // Hier wird startNewRound() aufgerufen
                            });
                            _saveGameState();
                          },
                          style: appButtonStyle(
                            backgroundColor: AppPalette.surfaceAlt,
                            foregroundColor: AppPalette.primary,
                            borderColor: AppPalette.border,
                            minimumSize: const Size(48, 52),
                          ),
                          child: const Text(
                            'NEUE RUNDE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text(
                                  'Spiel wirklich zurücksetzen?',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                                content: const Text(
                                  'Das aktuelle Spiel wird in der Historie gespeichert und danach zurückgesetzt.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(dialogContext).pop(),
                                    child: const Text('Abbrechen'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(dialogContext).pop();
                                      try {
                                        await _saveGameToHistory('reset');
                                      } catch (_) {
                                        // Zurücksetzen soll trotzdem funktionieren.
                                      }
                                      resetRound();
                                      await _saveGameState();
                                    },
                                    style: appButtonStyle(
                                      backgroundColor: AppPalette.danger,
                                      minimumSize: const Size(120, 44),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                    child: const Text('Zurücksetzen'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: appButtonStyle(
                          backgroundColor: AppPalette.background,
                          foregroundColor: AppPalette.textPrimary,
                          borderColor: AppPalette.border,
                          minimumSize: const Size(52, 52),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(
                          Icons.refresh,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showPrizeMoneyDialog(BuildContext context) {
    List<Player> sortedPlayers = List<Player>.from(widget.players);
    sortedPlayers.sort((a, b) => calculateTotalPointsPerPlayer()[b.name]!.compareTo(calculateTotalPointsPerPlayer()[a.name]!));

    Map<String, Map<String, double>> prizeMoneyMap = {};
    String selectedMultiplier = '0.05'; // Startwert für den Multiplikator

    // Berechnung des Preisgeldes mit dem Multiplikator 0,05
    _calculatePrizeMoney(sortedPlayers, prizeMoneyMap, selectedMultiplier);

    // Anzeige des Preisgeld-Dialogs
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.white,
              child: Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.white, // Weißer Hintergrund für den Container
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'SCHULDEN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Zentriertes Dropdown-Widget für die Auswahl des Multiplikators
                    Container(
                      alignment: Alignment.center,
                      child: DropdownButton<String>(
                        value: selectedMultiplier,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedMultiplier = newValue!;
                            // Nach dem Ändern des Multiplikators die Beträge neu berechnen und aktualisieren
                            _calculatePrizeMoney(sortedPlayers, prizeMoneyMap, selectedMultiplier);
                          });
                        },
                        dropdownColor: Colors.white, // Weißer Hintergrund für das Dropdown-Menü
                        items: <String>['0.05', '0.10', '0.15', '0.20'].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value + ' Cent'),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: prizeMoneyMap.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key} an',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: entry.value.entries.map((innerEntry) {
                                final amount = innerEntry.value.abs().toInt();
                                final debtKey = _debtKey(selectedMultiplier, entry.key, innerEntry.key, amount);
                                final isPaid = paidDebtKeys.contains(debtKey);

                                void toggleDebt(bool value) {
                                  setState(() {
                                    if (value) {
                                      paidDebtKeys.add(debtKey);
                                    } else {
                                      paidDebtKeys.remove(debtKey);
                                    }
                                  });
                                  _saveGameState();
                                }

                                return InkWell(
                                  onTap: () => toggleDebt(!isPaid),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${innerEntry.key} ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            decoration: isPaid ? TextDecoration.lineThrough : null,
                                            color: isPaid ? AppPalette.textSecondary : AppPalette.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: isPaid ? AppPalette.textSecondary : AppPalette.textPrimary,
                                      ),
                                      Text(
                                        ' $amount €', // Eurobetrag
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold, // Fett für den Betrag
                                          fontSize: 16,
                                          decoration: isPaid ? TextDecoration.lineThrough : null,
                                          color: isPaid ? AppPalette.textSecondary : AppPalette.textPrimary,
                                        ),
                                      ),
                                      Checkbox(
                                        value: isPaid,
                                        onChanged: (value) => toggleDebt(value ?? false),
                                        activeColor: AppPalette.success,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 8),
                          ],
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'OK',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }




// Funktion zur Berechnung des Preisgeldes mit dem ausgewählten Multiplikator
  void _calculatePrizeMoney(List<Player> sortedPlayers, Map<String, Map<String, double>> prizeMoneyMap, String selectedMultiplier) {
    prizeMoneyMap.clear();
    for (int i = 0; i < sortedPlayers.length - 1; i++) {
      Player player1 = sortedPlayers[i];
      for (int j = i + 1; j < sortedPlayers.length; j++) {
        Player player2 = sortedPlayers[j];
        double difference = (calculateTotalPointsPerPlayer()[player2.name]! - calculateTotalPointsPerPlayer()[player1.name]!) * double.parse(selectedMultiplier);
        difference = difference.roundToDouble();

        if (prizeMoneyMap.containsKey(player1.name)) {
          prizeMoneyMap[player1.name]![player2.name] = difference;
        } else {
          prizeMoneyMap[player1.name] = {player2.name: difference};
        }
      }
    }
  }





  void startNewRound() {
    // Finde den Index des aktuellen ausgewählten Spielers mit rotem Namen
    int currentIndexName = selectedDropdownPlayer != null ? widget.players.indexOf(selectedDropdownPlayer!) : -1;

    // Berechne den Index des nächsten Spielers im Uhrzeigersinn für den roten Namen
    int nextIndexName = (currentIndexName + 1) % widget.players.length;

    // Wähle den nächsten Spieler für den roten Namen aus und aktualisiere den Zustand
    setState(() {
      // Setze die rote Markierung für den aktuellen Spieler zurück
      if (selectedDropdownPlayer != null) {
        selectedDropdownPlayer!.isSelected = false;
      }

      // Wähle den nächsten Spieler für den roten Namen aus und setze die rote Markierung
      selectedDropdownPlayer = widget.players[nextIndexName];
      selectedDropdownPlayer!.isSelected = true;
    });

    // Finde den Index des aktuellen Spielers mit dem roten Punkt
    int currentIndexDot = widget.players.indexWhere((player) => player.hasRedDot);

    // Berechne den Index des nächsten Spielers im Uhrzeigersinn für den roten Punkt
    int nextIndexDot = (currentIndexDot + 1) % widget.players.length;

    // Setze den roten Punkt für alle Spieler zurück
    for (var player in widget.players) {
      player.hasRedDot = false;
    }

    // Wähle den nächsten Spieler für den roten Punkt aus und aktualisiere den Zustand
    setState(() {
      // Wähle den nächsten Spieler für den roten Punkt aus und setze den roten Punkt
      widget.players[nextIndexDot].hasRedDot = true;

      // Setze den roten Namen auf den Spieler mit dem roten Punkt
      selectedDropdownPlayer = widget.players[nextIndexDot];
      selectedDropdownPlayer!.isSelected = true;
    });
    _saveGameState();
  }




  void _automaticallySelectNextPlayer() {
    // Finde den Index des aktuellen ausgewählten Spielers
    int currentIndex = selectedDropdownPlayer != null ? widget.players.indexOf(selectedDropdownPlayer!) : -1;

    // Berechne den Index des nächsten Spielers im Uhrzeigersinn
    int nextIndex = (currentIndex + 1) % widget.players.length;

    // Wähle den nächsten Spieler aus und aktualisiere den Zustand
    setState(() {
      selectedDropdownPlayer = widget.players[nextIndex];
      selectedGridViewPlayer = selectedDropdownPlayer; // Optional: Update auch den im GridView ausgewählten Spieler
    });
    _saveGameState();
  }

  void _handleLeftXButtonPress(Player player) {
    // Behandele den Klick auf das linke X für den angegebenen Spieler
    // Füge +5 Punkte zum Spieler unter Berücksichtigung des ausgewählten Multiplikators hinzu
    if (player != null && selectedMultiplier != null) {
      setState(() {
        player.points += 5 * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;
        player.isVisible = false; // Spieler ausblenden
      });

      // Überprüfe, ob alle Spieler ausgeblendet sind
      if (widget.players.every((player) => !player.isVisible)) {
        // Wenn alle Spieler ausgeblendet sind, blende sie automatisch wieder ein und setze den Multiplikator auf x1 zurück
        setState(() {
          for (var player in widget.players) {
            player.isVisible = true;
          }

          // Multiplikator auf x1 zurücksetzen
          selectedMultiplier = pointsMultipliers[0];
          selectedValue = 'x${selectedMultiplier!.multiplier}';

          // Automatisch den nächsten Spieler im Uhrzeigersinn auswählen
          _automaticallySelectNextPlayer();
        });
      }
    }
    _saveGameState();
  }

  void _handleRightXButtonPress(Player player) {
    // Behandle den Klick auf das rechte X für den angegebenen Spieler
    // Füge +10 Punkte zum Spieler unter Berücksichtigung des ausgewählten Multiplikators hinzu
    if (player != null && selectedMultiplier != null) {
      setState(() {
        player.points += 10 * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;
        player.isVisible = false; // Spieler ausblenden
      });

      // Überprüfe, ob alle Spieler ausgeblendet sind
      if (widget.players.every((player) => !player.isVisible)) {
        // Wenn alle Spieler ausgeblendet sind, blende sie automatisch wieder ein und setze den Multiplikator auf x1 zurück
        setState(() {
          for (var player in widget.players) {
            player.isVisible = true;
          }

          // Multiplikator auf x1 zurücksetzen
          selectedMultiplier = pointsMultipliers[0];
          selectedValue = 'x${selectedMultiplier!.multiplier}';

          // Automatisch den nächsten Spieler im Uhrzeigersinn auswählen
          _automaticallySelectNextPlayer();
        });
      }
    }
    _saveGameState();
  }

  void _handleMinusButtonPress(Player player) {
    // Behandle den Klick auf den Minus-Button für den angegebenen Spieler
    // Füge +1 Punkt zum Spieler unter Berücksichtigung des ausgewählten Multiplikators hinzu
    if (player != null && selectedMultiplier != null) {
      setState(() {
        player.points += 1 * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;
        player.isVisible = false; // Spieler ausblenden
      });

      // Überprüfe, ob alle Spieler ausgeblendet sind
      if (widget.players.every((player) => !player.isVisible)) {
        // Wenn alle Spieler ausgeblendet sind, blende sie automatisch wieder ein und setze den Multiplikator auf x1 zurück
        setState(() {
          for (var player in widget.players) {
            player.isVisible = true;
          }

          // Multiplikator auf x1 zurücksetzen
          selectedMultiplier = pointsMultipliers[0];
          selectedValue = 'x${selectedMultiplier!.multiplier}';

          // Automatisch den nächsten Spieler im Uhrzeigersinn auswählen
          _automaticallySelectNextPlayer();
        });
      }
    }
    _saveGameState();
  }

  void _applyPointsToPlayer(Player player, int points) {
    // Füge Punkte zum Spieler hinzu unter Berücksichtigung des Multiplikators
    if (player != null && selectedMultiplier != null && player.isVisible) {
      setState(() {
        player.points += points * selectedMultiplier!.multiplier;
        calculatedPoints = player.points;

        // Stelle sicher, dass kein Spieler unter 0 Punkte fällt
        if (player.points < 0) {
          player.points = 0;
        }
        player.isVisible = false; // Spieler ausblenden
      });

      // Aktualisiere die Gesamtpunktzahl des Spielers
      updateTotalPoints(player);

      // Überprüfe, ob alle Spieler ausgeblendet sind
      if (widget.players.every((player) => !player.isVisible)) {
        // Wenn alle Spieler ausgeblendet sind, blende sie automatisch wieder ein und setze den Multiplikator auf x1 zurück
        setState(() {
          for (var player in widget.players) {
            player.isVisible = true;
          }
          // Multiplikator auf x1 zurücksetzen
          selectedMultiplier = pointsMultipliers[0];
        });

        // Automatisch den nächsten Spieler im Uhrzeigersinn auswählen
        _automaticallySelectNextPlayer();
      }
    }
    _saveGameState();
  }


  void updateTotalPoints(Player player) {
    // Aktualisiere die Gesamtpunktzahl des Spielers
    Map<String, int> totalPointsPerPlayer = calculateTotalPointsPerPlayer();
    int totalPoints = totalPointsPerPlayer[player.name] ?? 0;
    totalPoints += calculatedPoints;

    // Stelle sicher, dass keine Minuspunkte für die Gesamtpunktzahl angezeigt werden
    totalPoints = totalPoints < 0 ? 0 : totalPoints;

    totalPointsPerPlayer[player.name] = totalPoints;

    // Setze die Gesamtpunktzahl für jeden Spieler neu
    setState(() {
      totalPointsPerPlayer = totalPointsPerPlayer;

      // Hier wird der aktuelle Punktestand zum totalPoints der Spieler hinzugefügt
      player.totalPoints = totalPoints;
    });
  }


  void _showMultiplierMenu(BuildContext context) {
    setState(() {
      // Hier wird der Index des aktuellen Multiplikators gefunden
      int currentIndex = pointsMultipliers.indexOf(selectedMultiplier!);

      // Hier wird der Index des nächsten Multiplikators berechnet
      int nextIndex = (currentIndex + 1) % pointsMultipliers.length;

      // Hier wird der nächste Multiplikator ausgewählt
      selectedMultiplier = pointsMultipliers[nextIndex];
      selectedValue = 'x${selectedMultiplier!.multiplier}';
    });
    _saveGameState();
  }
}