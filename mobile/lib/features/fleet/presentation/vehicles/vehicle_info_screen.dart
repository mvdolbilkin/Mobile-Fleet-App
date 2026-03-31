import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/theme.dart';
import '../../domain/vehicle.dart';

class VehicleInfoScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const VehicleInfoScreen({super.key, this.vehicle});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.vehicle != null 
              ? '${widget.vehicle!.plateNumber} ${widget.vehicle!.model} ${widget.vehicle!.year}'
              : 'Информация об автомобиле',
          style: AppTheme.appBarTitle,
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Главное'),
            Tab(text: 'Детали'),
            Tab(text: 'Водители'),
            Tab(text: 'Фотоконтроль'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMainTab(),
          _buildDetailsTab(),
          _buildDriversTab(),
          _buildPhotoControlTab(),
        ],
      ),
    );
  }

  Widget _buildMainTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCards(),
        const SizedBox(height: 16),
        _buildBanner(),
        const SizedBox(height: 16),
        _buildTariffsSection(),
        const SizedBox(height: 16),
        _buildRentSection(),
        const SizedBox(height: 24),
        _buildSettingsSection(),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildInfoCard('В простое', '0 дней')),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoCard('Количество поездок', '0')),
            ],
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildInfoCard('Среднее время на линии', '0 мин')),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoCard('Доход', '5 ₽')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Подтвердите право использования и получите полный контроль над автомобилем',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('Подтвердить право использования'),
          ),
        ],
      ),
    );
  }

  Widget _buildTariffsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Включенные тарифы', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Комфорт, Комфорт+, Эконом, Доставка, Межгород', style: TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
  
  Widget _buildRentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Условие аренды', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('7/0 3000₽ • Схема\n1000₽ • Депозит', style: TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Настройки', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSettingGroup(
          title: 'Брендинг',
          subtitle: 'После добавления оклейки или Lightbox, водитель должен пройти фотоконтроль в приложении Про',
          cards: [
            _buildSettingCard(
              title: 'Оклейка',
              status: 'Ожидаем фотоконтроль',
              description: 'Мы автоматически обновим статус, когда водитель пройдет фотоконтроль',
              icon: Icons.warning_rounded,
              iconColor: Colors.orange,
              showDelete: true,
            ),
            _buildActionCard(
              title: 'Lightbox',
              subtitle: 'Чтобы установить Lightbox, сначала удалите Digitalbox',
            ),
            _buildSettingCard(
              title: 'Digitalbox',
              status: 'Подтверждение не требуется',
              icon: Icons.check_circle,
              iconColor: Colors.green,
              showDelete: true,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSettingGroup(
          title: 'Детские кресла',
          subtitle: 'Детские кресла, которые принадлежат водителю, может редактировать только сам водитель в приложении Про',
          cards: [
            _buildChildSeatCard(
              title: 'Кресло 1',
              status: 'Фотоконтроль просрочен',
              categories: '0',
              id: '6e755cad-254d-4225-a2c6-fd04d1bc5ae4',
            ),
            _buildChildSeatCard(
              title: 'Кресло 2',
              status: 'Фотоконтроль просрочен',
              categories: '0, 1',
              id: '4edfcfb2-801f-4f9b-ab3a-0481994b07a6',
            ),
          ],
        ),
        const SizedBox(height: 40), // Bottom padding
      ],
    );
  }

  Widget _buildSettingGroup({required String title, required String subtitle, required List<Widget> cards}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: cards.map((card) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: card,
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String status,
    String? description,
    required IconData icon,
    required Color iconColor,
    bool showDelete = false,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (showDelete)
                const Icon(Icons.delete_outline, size: 20, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 8),
          Text(status, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          if (description != null) ...[
            const SizedBox(height: 16),
            Text(description, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ],
      ),
    );
  }

  Widget _buildActionCard({required String title, required String subtitle}) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChildSeatCard({
    required String title, 
    required String status, 
    required String categories,
    required String id,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.edit_outlined, size: 20, color: Colors.black54),
              const SizedBox(width: 8),
              const Icon(Icons.delete_outline, size: 20, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 8),
          Text(status, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: categories, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const TextSpan(text: ' • категории', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text('$id • ID', style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailSection(
          'Адрес парковки',
          'Водителям будет легче найти ваш автомобиль на карте',
          const Text('Москва, улица Цюрупы, 30/63', style: TextStyle(fontSize: 15)),
        ),
        _buildDetailSection(
          'Владелец',
          'Кому принадлежит право использования',
          const Text('Таксопарк', style: TextStyle(fontSize: 15)),
        ),
        _buildDetailSection(
          'Об автомобиле',
          'Детали',
          _buildDetailGrid([
            {'СТС': '—'}, {'Год выпуска': widget.vehicle?.year ?? '—'},
            {'Дата выдачи СТС': '—'}, {'Номер кузова': '—'},
            {'Госномер': widget.vehicle?.plateNumber ?? '—'}, {'Цвет': widget.vehicle?.color ?? '—'},
            {'VIN': widget.vehicle?.id ?? '—'}, {'КПП': '—'},
            {'Марка': widget.vehicle?.model ?? '—'}, {'Вид топлива': '—'},
            {'Модель': '—'}, {'Тип ТС': '—'},
            {'Пробег': widget.vehicle != null ? '${widget.vehicle!.mileage} км' : '—'},
          ]),
        ),
        _buildDetailSection(
          'Комплектация',
          'Дополнительная информация',
          _buildDetailGrid([
            {'Кондиционер': 'Есть'},
          ]),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, String subtitle, Widget content, {bool showDivider = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          content,
          if (showDivider) ...[
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFEEEEEE), height: 1),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailGrid(List<Map<String, String>> items) {
    List<Widget> rows = [];
    for (int i = 0; i < items.length; i += 2) {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildDetailItem(items[i].keys.first, items[i].values.first)),
          const SizedBox(width: 16),
          if (i + 1 < items.length)
            Expanded(child: _buildDetailItem(items[i + 1].keys.first, items[i + 1].values.first))
          else
            const Expanded(child: SizedBox()),
        ],
      ));
      if (i + 2 < items.length) {
        rows.add(const SizedBox(height: 16));
      }
    }
    return Column(children: rows);
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15)),
      ],
    );
  }

  Widget _buildDriversTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDriverCard(
          status: 'Выполняет заказы',
          statusColor: Colors.green,
          state: 'Офлайн',
          name: 'Большаков Владислав Валерьевич',
          license: '1351770913',
          phone: '+79603646186',
          date: '29.05.2025',
        ),
        _buildDriverCard(
          status: 'Сотрудничество завершено',
          statusColor: Colors.red,
          state: 'Офлайн',
          name: 'Тестов Тест Тестович',
          license: '6882888888',
          phone: '+79998232323',
          date: '19.11.2025',
        ),
      ],
    );
  }

  Widget _buildDriverCard({
    required String status,
    required Color statusColor,
    required String state,
    required String name,
    required String license,
    required String phone,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Icon(Icons.open_in_new, size: 18, color: Colors.blue),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w500, fontSize: 13)),
              Text(state, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ]
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFEEEEEE)),
          _buildDriverInfoRow('ВУ', license),
          const SizedBox(height: 8),
          _buildDriverInfoRow('Телефон', phone, isLink: true),
          const SizedBox(height: 8),
          _buildDriverInfoRow('Дата принятия', date),
        ],
      ),
    );
  }

  Widget _buildDriverInfoRow(String label, String value, {bool isLink = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value, 
          style: TextStyle(
            color: isLink ? Colors.blue : Colors.black87, 
            fontSize: 13,
            decoration: isLink ? TextDecoration.underline : null,
            decorationColor: Colors.blue,
            decorationThickness: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoControlTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/waiting-man.svg',
            width: 250,
          ),
          const SizedBox(height: 24),
          const Text(
            'Ещё нет фотографий',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Подождите, пока водитель загрузит их',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60), // Add a little extra space to center better optically
        ],
      ),
    );
  }
}
