import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/models/group.dart';
import 'package:leak_guard/models/water_usage_data.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/widgets/custom_app_bar.dart';
import 'package:leak_guard/widgets/graph_water_usage_widget.dart';

class WaterUsageScreen extends StatefulWidget {
  const WaterUsageScreen({super.key, required this.group});
  final Group group;

  @override
  State<WaterUsageScreen> createState() => _WaterUsageScreenState();
}

class _WaterUsageScreenState extends State<WaterUsageScreen> {
  final List<String> _options = [
    "This\nhour",
    "This\nday",
    "last\ndays",
    "last\nmonths"
  ];
  late String _option = _options[0];

  Widget _buildButtons() {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildButton(_options[0]),
          const SizedBox(width: 20),
          _buildButton(_options[1]),
        ]),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildButton(_options[2]),
          const SizedBox(width: 20),
          _buildButton(_options[3]),
        ]),
      ],
    );
  }

  Widget _buildButton(String option) {
    return NeumorphicButton(
      padding: const EdgeInsets.all(8),
      onPressed: () {
        setState(() {
          _option = _options[_options.indexOf(option)];
          print(_option);
        });
      },
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        depth: option == _option ? -6 : 6,
      ),
      child: SizedBox(
        width: 100,
        height: 100,
        child: Center(
          child: Text(
            option,
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Future<(List<WaterUsageData>, List<String>)> _getData() async {
    List<WaterUsageData> data = [
      WaterUsageData(DateTime.now(), 110),
      WaterUsageData(DateTime.now(), 120),
      WaterUsageData(DateTime.now(), 130),
      WaterUsageData(DateTime.now(), 140),
      WaterUsageData(DateTime.now(), 150),
      WaterUsageData(DateTime.now(), 160),
      WaterUsageData(DateTime.now(), 170),
      WaterUsageData(DateTime.now(), 180),
      WaterUsageData(DateTime.now(), 190),
      WaterUsageData(DateTime.now(), 200),
      WaterUsageData(DateTime.now(), 210),
      WaterUsageData(DateTime.now(), 220),
    ];

    List<String> labels = [
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "10",
      "11",
      "12",
    ];

    if (_option == _options[0]) {
      labels = [
        "00",
        "05",
        "10",
        "15",
        "20",
        "25",
        "30",
        "35",
        "40",
        "45",
        "50",
        "55",
      ];
      return (await widget.group.getWaterUsageDataThisHour(12), labels);
    } else if (_option == _options[1]) {
      labels = [
        "00",
        "02",
        "04",
        "06",
        "08",
        "10",
        "12",
        "14",
        "16",
        "18",
        "20",
        "22",
      ];
      return (await widget.group.getWaterUsageDataThisDay(12), labels);
    } else if (_option == _options[2]) {
      data = await widget.group.getWaterUsageDataLastDays(12);

      labels = [];
      for (var i = 0; i < data.length; i++) {
        labels.add((data[i].date.day).toString());
      }
      return (data, labels);
    } else {
      data = await widget.group.getWaterUsageDataLastMonths(12);

      labels = [];
      for (var i = 0; i < data.length; i++) {
        labels.add((data[i].date.month).toString());
      }
      return (data, labels);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onLeadingTap: () => Navigator.pop(context),
        leadingIcon: const Icon(Icons.arrow_back),
        title: widget.group.name,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: Future.wait([
          _getData(),
        ]).then((results) => {
              'data': results[0].$1,
              'labels': results[0].$2,
            }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: MyColors.lightThemeFont,
              ),
            );
          }

          Map<String, dynamic> data = snapshot.data!;
          for (var i = 0; i < data['data'].length; i++) {
            print(data['data'][i]);
            print(data['data'][i]);
          }
          print(data['data'].length);

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: GraphWaterUsageWidget(
                    data: data['data'], labels: data['labels']),
              ),
              const SizedBox(height: 20),
              _buildButtons(),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}
