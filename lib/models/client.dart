class Client {
  final String id;
  final String name;
  final String gstin;
  final String address;
  final String email;
  final String phone;
  final String primaryContact;
  final String notes;

  const Client({
    required this.id,
    required this.name,
    this.gstin = '',
    this.address = '',
    this.email = '',
    this.phone = '',
    this.primaryContact = '',
    this.notes = '',
  });

  Client copyWith({
    String? id,
    String? name,
    String? gstin,
    String? address,
    String? email,
    String? phone,
    String? primaryContact,
    String? notes,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      gstin: gstin ?? this.gstin,
      address: address ?? this.address,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      primaryContact: primaryContact ?? this.primaryContact,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gstin': gstin,
      'address': address,
      'email': email,
      'phone': phone,
      'primaryContact': primaryContact,
      'notes': notes,
    };
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'] ?? '',
      gstin: json['gstin'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      primaryContact: json['primaryContact'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}
