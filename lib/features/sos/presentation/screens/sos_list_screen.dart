import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pakland/features/sos/presentation/controllers/sos_controller.dart';
import 'package:pakland/features/tickets/presentation/controllers/tickets_controller.dart';
import 'package:pakland/core/widgets/widgets/app_bar.dart';
import 'package:pakland/core/utils/screen_helper.dart';
import 'package:pakland/features/tickets/data/models/ticket_models.dart';

class SOSListView extends StatefulWidget {
  const SOSListView({super.key});
  @override
  State<SOSListView> createState() => _SOSListViewState();
}

class _SOSListViewState extends State<SOSListView> {
  final TicketController controller = Get.find();

  @override
  void initState() { super.initState(); controller.loadActiveSOSEmergencies(); }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTV ? 70 : kToolbarHeight),
        child: CustomAppBar(title: 'SOS Tickets'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        final items = controller.activeSOSTickets;
        if (items.isEmpty) return Center(child: Text('No SOS tickets', style: TextStyle(fontSize: isTV ? 20 : 16)));

        return RefreshIndicator(
          onRefresh: () async => await controller.loadActiveSOSEmergencies(),
          child: isTV
              ? _buildTVGrid(items)
              : _buildMobileList(items),
        );
      }),
    );
  }

  Widget _buildMobileList(List<TicketModel> items) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final ticket = items[index];
        return ListTile(
          leading: const Icon(Icons.emergency, color: Colors.red),
          title: Text('${ticket.title} - ${ticket.status}'),
          subtitle: Text(ticket.description, maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: () => Get.toNamed('/tickets/${ticket.id}', arguments: {'ticket': ticket}),
        );
      },
    );
  }

  Widget _buildTVGrid(List<TicketModel> items) {
    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final ticket = items[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.red[50],
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Get.toNamed('/tickets/${ticket.id}', arguments: {'ticket': ticket}),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(children: [
                Icon(Icons.emergency, color: Colors.red, size: 32),
                SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${ticket.title} - ${ticket.status}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text(ticket.description, style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
                ])),
                Icon(Icons.arrow_forward_ios, color: Colors.red[300], size: 18),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class SOSCreateView extends StatefulWidget {
  const SOSCreateView({super.key});
  @override
  State<SOSCreateView> createState() => _SOSCreateViewState();
}

class _SOSCreateViewState extends State<SOSCreateView> {
  final TicketController controller = Get.find<TicketController>();
  final type = RxString('Medical');
  final descCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final latCtrl = TextEditingController();
  final lngCtrl = TextEditingController();
  String? userId;

  @override
  void initState() { super.initState(); _loadUserId(); }

  Future<void> _loadUserId() async {
    final storage = const FlutterSecureStorage();
    userId = await storage.read(key: 'user_id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send SOS')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Obx(() => DropdownButtonFormField<String>(
            initialValue: type.value,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Type'),
            items: const [
              DropdownMenuItem(value: 'Medical', child: Text('Medical')),
              DropdownMenuItem(value: 'Fire', child: Text('Fire')),
              DropdownMenuItem(value: 'Police', child: Text('Police')),
              DropdownMenuItem(value: 'Accident', child: Text('Accident')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (v) => type.value = v ?? 'Medical',
          )),
          const SizedBox(height: 12),
          TextField(controller: descCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Description'), minLines: 3, maxLines: 5),
          const SizedBox(height: 12),
          TextField(controller: locationCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Location')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: latCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Latitude'), keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: lngCtrl, decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Longitude'), keyboardType: TextInputType.number)),
          ]),
        ]),
      ),
    );
  }
}