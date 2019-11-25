import 'dart:math';
import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart';

import 'package:charts_flutter_demo/custom_circle_symbol_renderer.dart';

class SimpleLineChart extends StatefulWidget {
  @override
  _SimpleLineChartState createState() => _SimpleLineChartState();
}

class _SimpleLineChartState extends State<SimpleLineChart> {
  int _lastY = 1;
  int _lastValue = 20;
  bool _pause = false;
  DateTime _time;
  Map<String, num> _measures;

  LineRendererConfig<DateTime> _lineRendererConfig = LineRendererConfig(
    includeArea: false,
    includeLine: true,
    includePoints: true,
    stacked: false,
    roundEndCaps: true,
    // dashPattern: [1, 0],
    radiusPx: 3.5,
    strokeWidthPx: 3.0,
  );

  List<Series<TimeSeriesSales, DateTime>> seriesData = List<Series<TimeSeriesSales, DateTime>>();
  List<Series<TimeSeriesSales, DateTime>> seriesData2 = List<Series<TimeSeriesSales, DateTime>>();

  final dataXY = [
    TimeSeriesSales(DateTime(2017, 10, 1), 20),
  ];

  @override
  void initState() {
    dataStream = createDataTimesStream();

    dataStream.listen((data) {
      setState(() {
        // _lineRendererConfig = null;

        dataXY.add(data);

        if (!_pause) {
          seriesData = _createSampleData(dataXY);
        }
      });
    });

    super.initState();
  }

  static List<Series<TimeSeriesSales, DateTime>> _createSampleData(List<TimeSeriesSales> data) {
    List<TimeSeriesSales> data2 = [TimeSeriesSales(data.first.time, data.last.sales), TimeSeriesSales(data.last.time, data.last.sales)];

    return [
      Series<TimeSeriesSales, DateTime>(
        id: 'Barrier',
        colorFn: (_, __) => MaterialPalette.green.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data2,
      ),
      Series<TimeSeriesSales, DateTime>(
        id: 'Sample Data',
        colorFn: (_, __) => MaterialPalette.black,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      ),
    ];
  }

  Stream<TimeSeriesSales> createDataTimesStream() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 3));

      _lastValue = Random().nextBool() ? _lastValue + Random().nextInt(5) : _lastValue - Random().nextInt(5);

      yield TimeSeriesSales(DateTime(2017, 10, ++_lastY), _lastValue);
    }
  }

  Stream<TimeSeriesSales> dataStream;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width,
            child: buildTimeSeriesChart(),
          ),
        ),
        SizedBox(height: 32.0),
        Text(_measures == null ? '' : _measures.toString())
      ],
    );
  }

  var renderer = CustomCircleSymbolRenderer("");

  TimeSeriesChart buildTimeSeriesChart() {
    return TimeSeriesChart(
      seriesData,
      animate: true,
      // domainAxis: EndPointsTimeAxisSpec(),
      defaultRenderer: _lineRendererConfig,
      behaviors: [
        PanAndZoomBehavior(),
        SeriesLegend(position: BehaviorPosition.bottom),
        SlidingViewport(),
        LinePointHighlighter(
          symbolRenderer: renderer,
          showHorizontalFollowLine: LinePointHighlighterFollowLineType.nearest,
          showVerticalFollowLine: LinePointHighlighterFollowLineType.nearest,
          dashPattern: [1],
          drawFollowLinesAcrossChart: true,
        ),
      ],
      selectionModels: [
        SelectionModelConfig(
          type: SelectionModelType.info,
          changedListener: (SelectionModel model) {
            if (model.hasDatumSelection) {
              setState(() {
                renderer.text = (model.selectedSeries[0].measureFn(model.selectedDatum[0].index)).toString();
              });
            }
          },
        ),
      ],
    );
  }
}

class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
