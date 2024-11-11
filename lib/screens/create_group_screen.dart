import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/central_unit.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/services/database_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/strings.dart';
import 'package:leak_guard/widgets/app_bar.dart';
import 'package:leak_guard/widgets/blurred_top_edge.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key, required this.groups});
  final List<Group> groups;

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _db = DatabaseService.instance;
  List<CentralUnit> centrals = [];

  List<CentralUnit> get chosenCentrals =>
      centrals.where((central) => central.chosen).toList();

  @override
  void initState() {
    super.initState();
    _db.getCentralUnits().then((value) {
      setState(() {
        centrals = value;
      });
    });
  }

  @override
  void dispose() {
    for (var central in centrals) {
      central.chosen = false;
    }
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final newGroup = Group(name: _nameController.text.trim());
      final groupId = await _db.addGroup(newGroup);
      newGroup.groupdID = groupId;

      // Dodaj wszystkie wybrane jednostki do grupy
      for (var central in chosenCentrals) {
        await _db.addCentralUnitToGroup(groupId, central.centralUnitID!);
      }

      // Dodaj do listy grup i wróć
      widget.groups.add(newGroup);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNeumorphicAppBar(
        height: 80,
        onLeadingTap: () => Navigator.pop(context),
        title: MyStrings.createGroup,
        trailingIcon: const Icon(Icons.check),
        onTrailingTap: _createGroup,
      ),
      body: BlurredTopEdge(
        height: 20,
        child: Form(
          key: _formKey,
          child: ListView.builder(
            itemCount: centrals.length + 4,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text('Group name',
                      style: Theme.of(context).textTheme.displayMedium),
                );
              }

              if (index == 1) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      depth: -5,
                      intensity: 0.8,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(12),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter group name...',
                        hintStyle: TextStyle(
                            color: MyColors.lightThemeFont.withOpacity(0.5)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a group name';
                        }
                        // Sprawdź czy nazwa nie jest już zajęta
                        if (widget.groups.any((g) =>
                            g.name.toLowerCase() ==
                            value.trim().toLowerCase())) {
                          return 'Group name already exists';
                        }
                        return null;
                      },
                    ),
                  ),
                );
              }

              if (index == 2) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Text('Chose central units',
                      style: Theme.of(context).textTheme.displayMedium),
                );
              }

              if (index == 3) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Neumorphic(
                    padding: const EdgeInsets.all(15),
                    style: NeumorphicStyle(
                      shape: NeumorphicShape.flat,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(12)),
                      depth: -10,
                      intensity: 0.8,
                      lightSource: LightSource.topLeft,
                      color: MyColors.background,
                    ),
                    child: NeumorphicButton(
                      style: NeumorphicStyle(
                        depth: 5,
                        intensity: 0.8,
                        boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: Center(
                        child: Text(
                          'Add new central unit',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                color: MyColors.lightThemeFont.withOpacity(0.4),
                              ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              final central = centrals[index - 4];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: NeumorphicButton(
                  style: NeumorphicStyle(
                    depth: central.chosen ? -5 : 5,
                    intensity: 0.8,
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      central.chosen = !central.chosen;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: SizedBox(
                      height: 60,
                      child: Center(
                        child: Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          central.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                color: !central.chosen
                                    ? MyColors.lightThemeFont
                                    : MyColors.lightThemeFont.withOpacity(0.7),
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}