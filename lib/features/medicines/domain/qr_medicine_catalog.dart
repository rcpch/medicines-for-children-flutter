// Lookup for QR-scanned medicines.
// Lookup entry for a medicine QR code.
class QrMedicineEntry {
  const QrMedicineEntry({
    required this.url,
    required this.name,
    required this.title,
  });

  final String url;
  final String name;
  final String title;
}

// Lookup entry for advice QR codes.
class QrAdviceEntry {
  const QrAdviceEntry({required this.url, required this.title});

  final String url;
  final String title;
}

// Lookup entry for external QR codes.
class QrExternalEntry {
  const QrExternalEntry({required this.url, required this.title});

  final String url;
  final String title;
}

// Type of QR scan result.
enum QrScanType { medicine, advice, external, unknown }

// Result wrapper for a parsed QR scan.
class QrScanResult {
  const QrScanResult._({
    required this.type,
    this.medicine,
    this.advice,
    this.external,
    this.rawValue,
  });

  final QrScanType type;
  final QrMedicineEntry? medicine;
  final QrAdviceEntry? advice;
  final QrExternalEntry? external;
  final String? rawValue;

  // Creates a medicine QR scan result.
  factory QrScanResult.medicine(QrMedicineEntry entry, String rawValue) =>
      QrScanResult._(
        type: QrScanType.medicine,
        medicine: entry,
        rawValue: rawValue,
      );

  // Creates an advice QR scan result.
  factory QrScanResult.advice(QrAdviceEntry entry, String rawValue) =>
      QrScanResult._(
        type: QrScanType.advice,
        advice: entry,
        rawValue: rawValue,
      );

  // Creates an external QR scan result.
  factory QrScanResult.external(QrExternalEntry entry, String rawValue) =>
      QrScanResult._(
        type: QrScanType.external,
        external: entry,
        rawValue: rawValue,
      );

  // Creates an unknown QR scan result.
  factory QrScanResult.unknown(String rawValue) =>
      QrScanResult._(type: QrScanType.unknown, rawValue: rawValue);
}

// Parses a raw QR value into a typed QR scan result.
QrScanResult parseQrScanResult(String rawValue) {
  final normalized = _normalizeUrl(rawValue);
  if (normalized.isEmpty) {
    return QrScanResult.unknown(rawValue);
  }
  final medicine = qrMedicineByUrl[normalized];
  if (medicine != null) {
    return QrScanResult.medicine(medicine, rawValue);
  }
  final advice = qrAdviceByUrl[normalized];
  if (advice != null) {
    return QrScanResult.advice(advice, rawValue);
  }
  final external = qrExternalByUrl[normalized];
  if (external != null) {
    return QrScanResult.external(external, rawValue);
  }
  return QrScanResult.unknown(rawValue);
}

// Normalizes QR URLs for matching against known entries.
String _normalizeUrl(String rawValue) {
  final trimmed = rawValue.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  final uri = Uri.tryParse(trimmed);
  if (uri == null) {
    return trimmed;
  }
  final normalized = Uri(
    scheme: uri.hasScheme ? uri.scheme.toLowerCase() : 'https',
    host: uri.host.toLowerCase(),
    path: uri.path,
    query: uri.query,
  );
  var value = normalized.toString();
  if (value.endsWith('/')) {
    value = value.substring(0, value.length - 1);
  }
  return value;
}

// Known QR medicine entries for quick add.
// Known QR medicine entries for quick add.
const qrMedicineEntries = <QrMedicineEntry>[
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/amoxicillin-for-bacterial-infections/',
    name: 'Amoxicillin',
    title: 'Amoxicillin for bacterial infections',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/ampicillin-for-infection/',
    name: 'Ampicillin',
    title: 'Ampicillin for infection',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/aspirin-for-prevention-of-blood-clots/',
    name: 'Aspirin',
    title: 'Aspirin for prevention of blood clots',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/atenolol-for-high-blood-pressure/',
    name: 'Atenolol',
    title: 'Atenolol for high blood pressure',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/atomoxetine-for-adhd/',
    name: 'Atomoxetine',
    title: 'Atomoxetine for ADHD',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/baclofen-for-muscle-spasm/',
    name: 'Baclofen',
    title: 'Baclofen for muscle spasm and dystonia',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/beclometasone-for-asthma-prevention/',
    name: 'Beclometasone',
    title: 'Beclometasone for asthma prevention',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/captopril-for-heart-failure/',
    name: 'Captopril',
    title: 'Captopril to improve heart function',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/carbamazepine-oral-for-preventing-seizures/',
    name: 'Carbamazepine (oral)',
    title: 'Carbamazepine (oral) for preventing seizures',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/carvedilol-for-heart-failure/',
    name: 'Carvedilol',
    title: 'Carvedilol to improve heart function',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/cetirizine-for-hayfever/',
    name: 'Cetirizine',
    title: 'Cetirizine for hayfever',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/chloramphenicol-for-eye-infections/',
    name: 'Chloramphenicol',
    title: 'Chloramphenicol for eye infections',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/chlorothiazide-for-chronic-lung-disease-heart-failure-ascites-and-high-blood-pressure/',
    name: 'Chlorothiazide',
    title:
        'Chlorothiazide for chronic lung disease and to improve heart function',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/clarithromycin-for-bacterial-infections/',
    name: 'Clarithromycin',
    title: 'Clarithromycin for bacterial infections',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/clobazam-for-preventing-seizures/',
    name: 'Clobazam',
    title: 'Clobazam for preventing seizures',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/clonazepam-for-preventing-seizures/',
    name: 'Clonazepam',
    title: 'Clonazepam for preventing seizures',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/clonidine-for-tourettes-syndrome-adhd-and-sleep-onset-disorder/',
    name: 'Clonidine',
    title: "Clonidine for Tourette's syndrome, ADHD and sleep-onset disorder",
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/co-amoxiclav-for-bacterial-infections/',
    name: 'Co-amoxiclav',
    title: 'Co-amoxiclav for bacterial infections',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/diclofenac-for-pain-and-inflammation/',
    name: 'Diclofenac',
    title: 'Diclofenac for pain and inflammation',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/enalapril-for-high-blood-pressure/',
    name: 'Enalapril',
    title: 'Enalapril for high blood pressure',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/enoximone-for-pulmonary-hypertension/',
    name: 'Enoximone',
    title: 'Enoximone for pulmonary hypertension',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/erythromycin-for-bacterial-infections/',
    name: 'Erythromycin',
    title: 'Erythromycin for bacterial infections',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/ethosuximide-for-preventing-seizures/',
    name: 'Ethosuximide',
    title: 'Ethosuximide for preventing seizures',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/flecainide-for-arrhythmias/',
    name: 'Flecainide',
    title: 'Flecainide for abnormal heart rhythms',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/flucloxacillin-for-bacterial-infections/',
    name: 'Flucloxacillin',
    title: 'Flucloxacillin for bacterial infections',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/glycerin-glycerol-suppositories-for-constipation/',
    name: 'Glycerin (glycerol) suppositories',
    title: 'Glycerin (glycerol) suppositories for constipation',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/guanfacine-for-adhd/',
    name: 'Guanfacine',
    title: 'Guanfacine for ADHD',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/ibuprofen-for-pain-and-inflammation/',
    name: 'Ibuprofen',
    title: 'Ibuprofen for pain and inflammation',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/labetalol-hydrochloride-for-hypertension/',
    name: 'Labetalol hydrochloride',
    title: 'Labetalol hydrochloride for high blood pressure',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/lacosamide-for-preventing-seizures/',
    name: 'Lacosamide',
    title: 'Lacosamide for preventing seizures',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/lactulose-for-constipation/',
    name: 'Lactulose',
    title: 'Lactulose for constipation',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/lamotrigine-for-preventing-seizures/',
    name: 'Lamotrigine',
    title: 'Lamotrigine for preventing seizures',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/lansoprazole-for-gastro-oesophageal-reflux-disease-gord-and-ulcers/',
    name: 'Lansoprazole',
    title:
        'Lansoprazole for gastro-oesophageal reflux disease (GORD) and ulcers',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/levetiracetam-for-preventing-seizures/',
    name: 'Levetiracetam',
    title: 'Levetiracetam for preventing seizures',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/lisdexamfetamine-for-adhd/',
    name: 'Lisdexamfetamine',
    title: 'Lisdexamfetamine for ADHD',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/lisinopril-for-high-blood-pressure/',
    name: 'Lisinopril',
    title: 'Lisinopril for high blood pressure',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/loratadine-for-allergy-symptoms/',
    name: 'Loratadine',
    title: 'Loratadine for allergy symptoms',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/melatonin-for-sleep-disorders/',
    name: 'Melatonin',
    title: 'Melatonin for sleep disorders',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/methylphenidate-for-adhd/',
    name: 'Methylphenidate',
    title: 'Methylphenidate for ADHD',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/metronidazole-for-bacterial-infections/',
    name: 'Metronidazole',
    title: 'Metronidazole for bacterial infections',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/midazolam-for-stopping-seizures/',
    name: 'Midazolam',
    title: 'Midazolam for stopping seizures',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/mometasone-furoate-inhaler-for-asthma-prevention-prophylaxis/',
    name: 'Mometasone furoate inhaler',
    title: 'Mometasone furoate inhaler for asthma prevention (prophylaxis)',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/montelukast-for-asthma/',
    name: 'Montelukast',
    title: 'Montelukast for asthma',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/movicol-for-constipation/',
    name: 'Movicol',
    title: 'Movicol for constipation',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/nitrofurantoin-for-urinary-tract-infections/',
    name: 'Nitrofurantoin',
    title: 'Nitrofurantoin for urinary tract infections',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/nystatin-for-candida-infections/',
    name: 'Nystatin',
    title: 'Nystatin for Candida infections',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/oxcarbazepine-for-preventing-seizures/',
    name: 'Oxcarbazepine',
    title: 'Oxcarbazepine for preventing seizures',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/oxybutynin-for-daytime-urinary-symptoms/',
    name: 'Oxybutynin',
    title: 'Oxybutynin for daytime urinary symptoms',
  ),
  QrMedicineEntry(
    url: 'https://www.medicinesforchildren.org.uk/medicines/paracetamol/',
    name: 'Paracetamol',
    title: 'Paracetamol for mild-to-moderate pain',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/penicillin-v-for-bacterial-infections/',
    name: 'Penicillin V',
    title: 'Penicillin V for bacterial infections',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/phenytoin-for-preventing-seizures/',
    name: 'Phenytoin',
    title: 'Phenytoin for preventing seizures',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/prednisolone-for-asthma/',
    name: 'Prednisolone',
    title: 'Prednisolone for asthma',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/ramipril-for-high-blood-pressure/',
    name: 'Ramipril',
    title: 'Ramipril for high blood pressure',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/rufinamide-for-preventing-seizures/',
    name: 'Rufinamide',
    title: 'Rufinamide for preventing seizures',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/salbutamol-inhaler-for-asthma-and-wheeze/',
    name: 'Salbutamol inhaler',
    title: 'Salbutamol inhaler for asthma and wheeze',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/salmeterol-inhaler-for-asthma/',
    name: 'Salmeterol inhaler',
    title: 'Salmeterol inhaler for asthma',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/sildenafil-for-pulmonary-hypertension/',
    name: 'Sildenafil',
    title: 'Sildenafil for pulmonary hypertension',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/sodium-chloride-for-hyponatraemia/',
    name: 'Sodium chloride',
    title:
        'Sodium chloride for hyponatraemia (low levels of sodium in the blood)',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/sodium-picosulfate-for-constipation/',
    name: 'Sodium picosulfate',
    title: 'Sodium picosulfate for constipation',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/sodium-valproate-for-preventing-seizures/',
    name: 'Sodium valproate',
    title: 'Sodium valproate for preventing seizures',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/spironolactone-for-heart-failure/',
    name: 'Spironolactone',
    title: 'Spironolactone to improve heart function',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/topiramate-for-preventing-seizures/',
    name: 'Topiramate',
    title: 'Topiramate for preventing seizures',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/trimethoprim-for-bacterial-infections/',
    name: 'Trimethoprim',
    title: 'Trimethoprim for bacterial infections',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/warfarin-for-the-treatment-and-prevention-of-thrombosis/',
    name: 'Warfarin',
    title: 'Warfarin for the treatment and prevention of blood clots',
  ),
  QrMedicineEntry(
    url:
        'https://www.medicinesforchildren.org.uk/medicines/zonisamide-for-preventing-seizures/',
    name: 'Zonisamide',
    title: 'Zonisamide for preventing seizures',
  ),
];

// Known QR advice entries for education links.
const qrAdviceEntries = <QrAdviceEntry>[
  QrAdviceEntry(
    url:
        'https://www.medicinesforchildren.org.uk/advice-guides/general-advice-for-medicines/',
    title: 'General advice for medicines',
  ),
  QrAdviceEntry(
    url:
        'https://www.medicinesforchildren.org.uk/advice-guides/general-advice-for-medicines/general-advice-about-antibiotics/',
    title: 'General advice about antibiotics',
  ),
  QrAdviceEntry(
    url:
        'https://www.medicinesforchildren.org.uk/advice-guides/general-advice-for-medicines/helping-your-child-to-swallow-tablets/',
    title: 'Helping your child to swallow tablets',
  ),
  QrAdviceEntry(
    url:
        'https://www.medicinesforchildren.org.uk/advice-guides/general-advice-for-medicines/side-effects-from-childrens-medicines/',
    title: "Side-effects from children's medicines",
  ),
  QrAdviceEntry(
    url:
        'https://www.medicinesforchildren.org.uk/advice-guides/giving-medicines/how-to-give-medicines-asthma-inhalers/',
    title: 'How to give medicines: inhalers for asthma',
  ),
  QrAdviceEntry(
    url:
        'https://www.medicinesforchildren.org.uk/advice-guides/giving-medicines/how-to-give-medicines-capsules/',
    title: 'How to give medicines: capsules',
  ),
  QrAdviceEntry(
    url:
        'https://www.medicinesforchildren.org.uk/advice-guides/giving-medicines/how-to-give-medicines-creams-and-ointments/',
    title: 'How to give medicines: creams and ointments',
  ),
  QrAdviceEntry(
    url:
        'https://www.medicinesforchildren.org.uk/advice-guides/giving-medicines/how-to-give-medicines-ear-drops/',
    title: 'How to give medicines: ear drops',
  ),
  QrAdviceEntry(
    url:
        'https://www.medicinesforchildren.org.uk/advice-guides/giving-medicines/how-to-give-medicines-eye-ointment/',
    title: 'How to give medicines: eye drops and eye ointment',
  ),
  QrAdviceEntry(
    url:
        'https://www.medicinesforchildren.org.uk/advice-guides/giving-medicines/how-to-give-medicines-granules-and-powders/',
    title: 'How to give medicines: granules and powders',
  ),
  QrAdviceEntry(
    url:
        'https://www.medicinesforchildren.org.uk/advice-guides/giving-medicines/how-to-give-medicines-liquid-medicine-using-an-oral-syringe-from-a-bottle-fitted-with-a-bung/',
    title:
        'How to give medicines: liquid medicine using an oral syringe from a bottle with a bung',
  ),
  QrAdviceEntry(
    url:
        'https://www.medicinesforchildren.org.uk/advice-guides/giving-medicines/how-to-give-medicines-liquid-medicine-using-an-oral-syringe-from-a-bottle-without-a-bung/',
    title:
        'How to give medicines: liquid medicine using an oral syringe from a bottle without a bung',
  ),
  QrAdviceEntry(
    url:
        'https://www.medicinesforchildren.org.uk/advice-guides/giving-medicines/how-to-give-medicines-rectal-medicines/',
    title: 'How to give medicines: rectal medicines',
  ),
  QrAdviceEntry(
    url:
        'https://www.medicinesforchildren.org.uk/advice-guides/giving-medicines/how-to-give-medicines-tablets/',
    title: 'How to give medicines: tablets',
  ),
  QrAdviceEntry(
    url:
        'https://www.medicinesforchildren.org.uk/advice-guides/giving-medicines/how-to-give-phosphate-or-calcium-from-effervescent-tablets/',
    title:
        'How to give calcium, phosphate or potassium using effervescent tablets',
  ),
];

// Known QR external entries for third-party resources.
const qrExternalEntries = <QrExternalEntry>[
  QrExternalEntry(
    url: 'https://eric.org.uk/childrens-bowels/constipation-in-children/',
    title: 'Constipation in children (ERIC)',
  ),
  QrExternalEntry(
    url: 'https://www.medicinesforchildren.org.uk/',
    title: 'Medicines for Children',
  ),
];

// Index for medicine entries keyed by normalized URL.
final Map<String, QrMedicineEntry> qrMedicineByUrl = {
  ..._buildUrlMap(qrMedicineEntries, (entry) => entry.url),
};

// Index for advice entries keyed by normalized URL.
final Map<String, QrAdviceEntry> qrAdviceByUrl = {
  ..._buildUrlMap(qrAdviceEntries, (entry) => entry.url),
};

// Index for external entries keyed by normalized URL.
final Map<String, QrExternalEntry> qrExternalByUrl = {
  ..._buildUrlMap(qrExternalEntries, (entry) => entry.url),
};

// Builds a map of normalized URLs to entries.
Map<String, T> _buildUrlMap<T>(
  List<T> entries,
  String Function(T entry) urlFor,
) {
  final map = <String, T>{};
  for (final entry in entries) {
    final raw = urlFor(entry);
    map[_normalizeUrl(raw)] = entry;
    map[_normalizeUrl('$raw/')] = entry;
  }
  return map;
}
