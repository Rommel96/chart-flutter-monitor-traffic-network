import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:monitor_traffic/models/data_ws.dart';
import 'package:mp_chart/mp/chart/line_chart.dart';
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/core/common_interfaces.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:web_socket_channel/io.dart';

class Chart extends StatefulWidget {
  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> implements OnChartValueSelectedListener {
  final channel = IOWebSocketChannel.connect(URL_SERVER);
  static const int VISIBLE_COUNT = 60; //Window visible of chart
  int _removalCounter = 0;
  LineChartController controller;

  @override
  void initState() {
    super.initState();
    controller = LineChartController();
    controller.data = LineData();
    ILineDataSet set0 = controller.data.getDataSetByIndex(0);
    set0 = _createSet(0);
    controller.data.addDataSet(set0);
    controller.data.addDataSet(_createSet(1));
    for (var nn = 0; nn < VISIBLE_COUNT; nn++) {
      addWithRemove(set0, controller.data, 50, 50);
    }

    channel.stream.listen((event) {
      final Message data = Message.fromJson(jsonDecode(event.toString()));
      addEntry(data.down.roundToDouble(), data.down.roundToDouble(),
          data.up.roundToDouble(), data.up.roundToDouble());
    });
  }

  LineDataSet _createSet(int ix) {
    LineDataSet set =
        LineDataSet(null, ix == 0 ? "Download" : "Upload" + " [Bytes]");
    set.setAxisDependency(AxisDependency.LEFT);
    set.setColor1(ix == 0 ? Colors.red : Colors.orangeAccent);
    set.setCircleColor(ColorUtils.RED);
    set.setDrawValues(false);
    set.setDrawCircles(false);
    return set;
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(controller);
  }

  @override
  void onNothingSelected() {}

  @override
  void onValueSelected(Entry e, Highlight h) {}

  void addWithRemove(ILineDataSet set0, LineData data, double y0, double y1) {
    double x = (set0.getEntryCount() + _removalCounter).toDouble();
    data.addEntry(
        Entry(
          x: x,
          y: y0,
        ),
        0);
    data.addEntry(
        Entry(
          x: x,
          y: y1,
        ),
        1);
    //remove entry which is out of visible range
    if (set0.getEntryCount() > VISIBLE_COUNT) {
      data.removeEntry2(_removalCounter.toDouble(), 0);
      data.removeEntry2(_removalCounter.toDouble(), 1);
      _removalCounter++;
    }
  }

  void addEntry(double downY0, double downY1, double upY0, double upY1) {
    LineData data = controller.data;
    if (data != null) {
      ILineDataSet set0 = data.getDataSetByIndex(0);
      addWithRemove(set0, data, downY0, upY0);

      ILineDataSet set1 = data.getDataSetByIndex(1);
      addWithRemove(set1, data, downY1, upY1);

      controller.setVisibleXRangeMaximum(VISIBLE_COUNT.toDouble());
      controller.moveViewToX(data.getEntryCount().toDouble());
      controller.state?.setStateIfNotDispose();
    }
  }
}
