import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sell_controller.dart';
import '../../../shared/widgets/custom_bottom_navbar.dart';

class SellView extends GetView<SellController> {
  const SellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        title: const Text(
          'Jual Barang Baru',
          style: TextStyle(
            color: Color(0xFFD4A574),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFD4A574)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informasi Barang', Icons.shopping_bag_outlined),
              const SizedBox(height: 12),
              _buildCard([
                _buildTextField(
                  controller: controller.titleController,
                  label: 'Nama Barang',
                  hint: 'Masukkan nama barang Anda',
                  icon: Icons.title_rounded,
                ),
                const SizedBox(height: 16),
                _buildCategoryDropdown(),
                const SizedBox(height: 16),
                _buildConditionDropdown(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: controller.descriptionController,
                  label: 'Deskripsi Barang',
                  hint: 'Jelaskan kondisi barang, kelengkapan, dll.',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle('Detail Pelelangan', Icons.gavel_outlined),
              const SizedBox(height: 12),
              _buildCard([
                _buildTextField(
                  controller: controller.startPriceController,
                  label: 'Harga Awal (Rp)',
                  hint: 'Contoh: 500000',
                  icon: Icons.monetization_on_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: controller.buyoutPriceController,
                  label: 'Harga Buyout (Rp) - Opsional',
                  hint: 'Langsung terjual jika bid mencapai harga ini',
                  icon: Icons.bolt_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildDurationSelector(),
              ]),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFB8865A), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C1810),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8DDD3).withOpacity(0.5), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A2C1A),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9F5F0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8DDD3), width: 1.2),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(color: Color(0xFF2C1810), fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              prefixIcon: Icon(icon, color: const Color(0xFFB8865A), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A2C1A),
          ),
        ),
        const SizedBox(height: 6),
        Obx(() {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9F5F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8DDD3), width: 1.2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedCategory.value,
                isExpanded: true,
                dropdownColor: const Color(0xFFF9F5F0),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFB8865A)),
                onChanged: (String? newValue) {
                  if (newValue != null) controller.selectedCategory.value = newValue;
                },
                items: controller.categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Color(0xFF2C1810), fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildConditionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kondisi Barang',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A2C1A),
          ),
        ),
        const SizedBox(height: 6),
        Obx(() {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9F5F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8DDD3), width: 1.2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedCondition.value,
                isExpanded: true,
                dropdownColor: const Color(0xFFF9F5F0),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFB8865A)),
                onChanged: (String? newValue) {
                  if (newValue != null) controller.selectedCondition.value = newValue;
                },
                items: controller.conditions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(color: Color(0xFF2C1810), fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Durasi Pelelangan',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A2C1A),
          ),
        ),
        const SizedBox(height: 6),
        Obx(() {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9F5F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8DDD3), width: 1.2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: controller.durationHours.value,
                isExpanded: true,
                dropdownColor: const Color(0xFFF9F5F0),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFB8865A)),
                onChanged: (int? newValue) {
                  if (newValue != null) controller.durationHours.value = newValue;
                },
                items: controller.durations.map<DropdownMenuItem<int>>((duration) {
                  return DropdownMenuItem<int>(
                    value: duration['hours'] as int,
                    child: Text(
                      duration['label'] as String,
                      style: const TextStyle(color: Color(0xFF2C1810), fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFD4A574), Color(0xFFB8865A)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A574).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.submitSell,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Unggah Barang & Mulai Lelang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
