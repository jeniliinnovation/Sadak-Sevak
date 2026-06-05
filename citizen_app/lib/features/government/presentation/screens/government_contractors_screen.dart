import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import 'package:sadak_sevak_citizen/features/government/data/government_repository.dart';
import 'package:sadak_sevak_citizen/features/government/domain/models/contractor_model.dart';

class GovernmentContractorsScreen extends StatefulWidget {
  const GovernmentContractorsScreen({super.key});

  @override
  State<GovernmentContractorsScreen> createState() => _GovernmentContractorsScreenState();
}

class _GovernmentContractorsScreenState extends State<GovernmentContractorsScreen> {
  final GovernmentRepository _repository = GovernmentRepository();
  bool _isLoading = true;
  List<Contractor> _contractors = [];

  @override
  void initState() {
    super.initState();
    _fetchContractors();
  }

  Future<void> _fetchContractors() async {
    try {
      final contractors = await _repository.getContractors();
      setState(() {
        _contractors = contractors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF4511E);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Contractors Management',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          )
        ],
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Contractor Directory',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list_rounded, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text('All Status', style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Contractors list
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: primaryOrange))
              : _contractors.isEmpty 
                ? const Center(child: Text('No contractors found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _contractors.length,
                    itemBuilder: (context, index) {
                      final contractor = _contractors[index];
                      final isActive = contractor.status == 'Active';

                      return FadeInUp(
                        duration: const Duration(milliseconds: 300),
                        delay: Duration(milliseconds: 50 * index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            children: [
                              // Contractor company icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade100),
                                ),
                                child: Icon(
                                  Icons.business_rounded,
                                  color: isActive ? primaryOrange : Colors.grey,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Contractor info details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contractor.companyName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF263238)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      contractor.specialization ?? 'General Contractor',
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(4)),
                                          child: Row(
                                            children: [
                                              Icon(Icons.star_rounded, size: 12, color: Colors.amber.shade700),
                                              const SizedBox(width: 4),
                                              Text(
                                                contractor.rating.toStringAsFixed(1),
                                                style: TextStyle(color: Colors.amber.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                                          child: Text(
                                            '3 Active Projects',
                                            style: TextStyle(color: Colors.blue.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Status display badge and Action
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      contractor.status ?? 'Active',
                                      style: TextStyle(
                                        color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: primaryOrange,
        icon: const Icon(Icons.add_business_rounded, color: Colors.white),
        label: const Text('Add Contractor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
