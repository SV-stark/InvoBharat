import '../models/hsn_code.dart';

class HsnRepository {
  static const List<HsnCode> commonCodes = [
    // --- SAC CODES (Services) ---
    // Professional Services
    HsnCode(
        code: '998211',
        description: 'Legal services including advocacy',
        rate: 18),
    HsnCode(
        code: '998221', description: 'Financial auditing services', rate: 18),
    HsnCode(
        code: '998222',
        description: 'Accounting, bookkeeping and auditing services',
        rate: 18),
    HsnCode(
        code: '998311',
        description: 'Management consulting and management services',
        rate: 18),
    HsnCode(
        code: '998312', description: 'Business consulting services', rate: 18),
    // IT Services
    HsnCode(
        code: '998313',
        description:
            'Information technology (IT) consulting and support services',
        rate: 18),
    HsnCode(
        code: '998314',
        description:
            'Information technology (IT) design and development services',
        rate: 18),
    HsnCode(
        code: '998315',
        description: 'Hosting and IT infrastructure provisioning services',
        rate: 18),
    HsnCode(
        code: '998316',
        description: 'IT infrastructure and network management services',
        rate: 18),
    HsnCode(
        code: '998319',
        description: 'Other information technology services n.e.c.',
        rate: 18),
    // Advertising & Marketing
    HsnCode(code: '998361', description: 'Advertising services', rate: 18),
    HsnCode(
        code: '998362',
        description: 'Purchase or sale of advertising space or time',
        rate: 18),
    HsnCode(
        code: '998363',
        description: 'Sale of advertising space in print media',
        rate: 5),
    HsnCode(
        code: '998364',
        description: 'Sale of television and radio advertising time',
        rate: 18),
    HsnCode(
        code: '998365',
        description: 'Sale of internet advertising space',
        rate: 18),
    HsnCode(
        code: '998366',
        description: 'Sale of other advertising space or time',
        rate: 18),
    HsnCode(
        code: '998399',
        description:
            'Other professional, technical and business services n.e.c.',
        rate: 18),
    // Rental & Leasing
    HsnCode(
        code: '997211',
        description:
            'Rental or leasing services involving own or leased residential property',
        rate: 18),
    HsnCode(
        code: '997212',
        description:
            'Rental or leasing services involving own or leased non-residential property',
        rate: 18),
    HsnCode(
        code: '997311',
        description:
            'Leasing or rental services of machinery and equipment without operator',
        rate: 18),
    // Construction
    HsnCode(
        code: '995411',
        description:
            'Construction services of single dwelling or multi dwelling or multi-storied residential buildings',
        rate: 12),
    HsnCode(
        code: '995412',
        description: 'Construction services of industrial buildings',
        rate: 18),
    HsnCode(
        code: '995413',
        description: 'Construction services of commercial buildings',
        rate: 18),
    HsnCode(
        code: '995414',
        description: 'Construction services of Other Buildings',
        rate: 18),
    HsnCode(
        code: '995415',
        description: 'Construction services of other civil engineering works',
        rate: 18),
    HsnCode(code: '995416', description: 'Site preparation services', rate: 18),
    HsnCode(
        code: '995419',
        description:
            'General construction services of other civil engineering works',
        rate: 18),
    // Telecom & Info
    HsnCode(
        code: '998411',
        description: 'Fixed-line telecommunication services',
        rate: 18),
    HsnCode(
        code: '998412',
        description: 'Mobile telecommunication services',
        rate: 18),
    HsnCode(
        code: '998413',
        description: 'Internet telecommunication services',
        rate: 18),
    // Maintenance
    HsnCode(
        code: '998711',
        description:
            'Maintenance and repair services of fabricated metal products, machinery and equipment',
        rate: 18),
    HsnCode(
        code: '998712',
        description:
            'Maintenance and repair services of office and accounting machinery',
        rate: 18),
    HsnCode(
        code: '998713',
        description:
            'Maintenance and repair services of computers and peripheral equipment',
        rate: 18),
    HsnCode(
        code: '998714',
        description:
            'Maintenance and repair services of transport machinery and equipment',
        rate: 18),
    HsnCode(
        code: '998715',
        description: 'Maintenance and repair services of electrical equipment',
        rate: 18),
    HsnCode(
        code: '998716',
        description:
            'Maintenance and repair services of office machinery and equipment',
        rate: 18),
    HsnCode(
        code: '998717',
        description:
            'Maintenance and repair services of elevators and escalators',
        rate: 18),
    // Transport
    HsnCode(
        code: '996511',
        description:
            'Road transport services of goods including letters, parcels, etc.',
        rate: 12), // GTA varies
    HsnCode(code: '996711', description: 'Cargo handling services', rate: 18),
    HsnCode(
        code: '996712',
        description: 'Storage and warehousing services',
        rate: 18),
    // Hospitality
    HsnCode(
        code: '996311',
        description:
            'Room or unit accommodation services provided by Hotels, Inns, etc.',
        rate: 12), // Varies 12/18
    HsnCode(
        code: '996313',
        description: 'Restaurant and mobile food service activities',
        rate: 5),
    HsnCode(
        code: '996331',
        description: 'Catering services',
        rate: 18), // Outdoor catering
    // Job Work
    HsnCode(
        code: '998811', description: 'Services by way of printing', rate: 12),
    HsnCode(
        code: '998812',
        description: 'Services by way of reproduction of recorded media',
        rate: 18),
    HsnCode(
        code: '998813', description: 'Tailoring services', rate: 5), // Varies

    // --- HSN CODES (Goods) ---
    // Electronics & Computer
    HsnCode(
        code: '847130',
        description:
            'Portable automatic data processing machines (Laptops, Tablets)',
        rate: 18),
    HsnCode(
        code: '847141',
        description: 'Other automatic data processing machines (Desktops)',
        rate: 18),
    HsnCode(
        code: '847160',
        description: 'Input or output units (Keyboards, Mice, Scanners)',
        rate: 18),
    HsnCode(
        code: '847170',
        description: 'Storage units (Hard Drives, SSDs, USBs)',
        rate: 18),
    HsnCode(
        code: '851711',
        description: 'Line telephone sets with cordless handsets',
        rate: 18),
    HsnCode(
        code: '851712',
        description:
            'Telephones for cellular networks or for other wireless networks (Mobile Phones)',
        rate: 18),
    HsnCode(
        code: '851762',
        description:
            'Machines for the reception, conversion and transmission or regeneration of voice, images or other data (Routers, Switches)',
        rate: 18),
    HsnCode(
        code: '852852',
        description:
            'Monitors capable of directly connecting to and designed for use with an automatic data processing machine',
        rate: 18),
    HsnCode(
        code: '852872',
        description:
            'Reception apparatus for television, whether or not incorporating radio-broadcast receivers (LED TVs)',
        rate: 28), // Often 18 if < 32"
    HsnCode(
        code: '854442',
        description:
            'Other electric conductors, fitted with connectors (Cables)',
        rate: 18),
    // Electricals
    HsnCode(
        code: '850440',
        description: 'Static converters (UPS, Inverters, Chargers)',
        rate: 18),
    HsnCode(
        code: '850610', description: 'Manganese dioxide batteries', rate: 18),
    HsnCode(
        code: '850720',
        description: 'Other lead-acid accumulators (Batteries for UPS)',
        rate: 28),
    HsnCode(
        code: '841451',
        description: 'Table, floor, wall, window, ceiling or roof fans',
        rate: 18),
    HsnCode(
        code: '841510',
        description: 'Window or wall air conditioning machines',
        rate: 28),
    HsnCode(
        code: '841810',
        description: 'Combined refrigerator-freezers',
        rate: 18),
    HsnCode(
        code: '851610',
        description:
            'Electric instantaneous or storage water heaters (Geysers)',
        rate: 18),
    // Furniture
    HsnCode(
        code: '940130',
        description: 'Swivel seats with variable height adjustment',
        rate: 18),
    HsnCode(
        code: '940310',
        description: 'Metal furniture of a kind used in offices',
        rate: 18),
    HsnCode(code: '940320', description: 'Other metal furniture', rate: 18),
    HsnCode(
        code: '940330',
        description: 'Wooden furniture of a kind used in offices',
        rate: 18),
    HsnCode(
        code: '940350',
        description: 'Wooden furniture of a kind used in the bedroom',
        rate: 18),
    HsnCode(code: '940360', description: 'Other wooden furniture', rate: 18),
    // Stationery & Paper
    HsnCode(
        code: '480210',
        description: 'Hand-made paper and paperboard',
        rate: 12),
    HsnCode(
        code: '482010',
        description: 'Registers, account books, note books, order books',
        rate: 12), // Can vary
    HsnCode(
        code: '482110',
        description: 'Paper or paperboard labels, printed',
        rate: 12),
    HsnCode(
        code: '490110',
        description: 'Printed books, brochures, leaflets',
        rate: 0), // Nil
    HsnCode(code: '960810', description: 'Ball point pens', rate: 12),
    // Construction Material
    HsnCode(code: '252329', description: 'Other Portland cement', rate: 28),
    HsnCode(
        code: '681011',
        description:
            'Building blocks and bricks of cement, concrete or artificial stone',
        rate: 12),
    HsnCode(
        code: '690721',
        description: 'Ceramic flags and paving, hearth or wall tiles',
        rate: 18),
    HsnCode(
        code: '721420',
        description:
            'Bars and rods, hot-rolled, in irregularly wound coils, of iron or non-alloy steel (TMT Bars)',
        rate: 18),
    // Textiles/Apparel
    HsnCode(
        code: '610510',
        description: 'Men\'s or boys\' shirts, knitted or crocheted (Cotton)',
        rate: 5), // If value < 1000
    HsnCode(
        code: '610910',
        description:
            'T-shirts, singlets and other vests, knitted or crocheted (Cotton)',
        rate: 5),
    HsnCode(code: '620311', description: 'Suits (Wool)', rate: 12),
    HsnCode(
        code: '620411',
        description: 'Women\'s or girls\' suits (Wool)',
        rate: 12),
    // Food (Packaged)
    HsnCode(code: '040510', description: 'Butter', rate: 12),
    HsnCode(code: '040690', description: 'Cheese', rate: 12),
    HsnCode(
        code: '090111',
        description: 'Coffee, not roasted, not decaffeinated',
        rate: 5),
    HsnCode(code: '090240', description: 'Black tea', rate: 5),
    HsnCode(code: '190531', description: 'Sweet biscuits', rate: 18),
    HsnCode(
        code: '210690',
        description: 'Food preparations not elsewhere specified or included',
        rate: 18),
    // Misc
    HsnCode(code: '901811', description: 'Electro-cardiographs', rate: 12),
    HsnCode(
        code: '300410',
        description: 'Medicaments containing penicillins',
        rate: 12), // Pharma often 12 or 5
    HsnCode(code: '330410', description: 'Lip make-up preparations', rate: 18),
    HsnCode(
        code: '340111',
        description:
            'Soap and organic surface-active products and preparations',
        rate: 18),
    HsnCode(
        code: '950300',
        description:
            'Tricycles, scooters, pedal cars and similar wheeled toys; dolls; other toys',
        rate: 12),
  ];

  Future<List<HsnCode>> search(String query) async {
    if (query.isEmpty) return [];
    final lower = query.toLowerCase();
    return commonCodes
        .where((e) =>
            e.code.toLowerCase().startsWith(lower) ||
            e.description.toLowerCase().contains(lower))
        .toList();
  }
}
