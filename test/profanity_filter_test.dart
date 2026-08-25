import 'package:flutter_test/flutter_test.dart';
import 'package:steam_tahmin_frontend/utils/profanity_filter.dart';

void main() {
  group('ProfanityFilter Tests', () {
    test('Turkish uppercase, lowercase and dotted OÇ variations', () {
      expect(ProfanityFilter.censor('OÇ'), '**');
      expect(ProfanityFilter.censor('oç'), '**');
      expect(ProfanityFilter.censor('OC'), '**');
      expect(ProfanityFilter.censor('oc'), '**');
      expect(ProfanityFilter.censor('OE'), '**');
      expect(ProfanityFilter.censor('oe'), '**');
      expect(ProfanityFilter.censor('O.Ç'), 'O*Ç');
      expect(ProfanityFilter.censor('o.ç'), 'o*ç');
      expect(ProfanityFilter.censor('O.C'), 'O*C');
      expect(ProfanityFilter.censor('o.c'), 'o*c');
      expect(ProfanityFilter.censor('o ç'), 'o*ç');
      expect(ProfanityFilter.censor('tam bir OÇ'), 'tam bir **');
      expect(ProfanityFilter.censor('tam bir oç'), 'tam bir **');
      expect(ProfanityFilter.censor('oçlar toplanmış'), 'o***r toplanmış');
    });

    test('Innocent Turkish words should NEVER be masked (False Positive check)', () {
      expect(
        ProfanityFilter.censor('Hayat güzel Tarla sula, maden kaz, Karıyı öp, çocuk yap'),
        'Hayat güzel Tarla sula, maden kaz, Karıyı öp, çocuk yap',
      );
      expect(ProfanityFilter.censor('çocuklar oyun oynuyor'), 'çocuklar oyun oynuyor');
      expect(ProfanityFilter.censor('bu bir deneme sürümüdür'), 'bu bir deneme sürümüdür');
      expect(ProfanityFilter.censor('malzeme listesi hazır'), 'malzeme listesi hazır');
      expect(ProfanityFilter.censor('normal bir gün'), 'normal bir gün');
      expect(ProfanityFilter.censor('dolu yağdı'), 'dolu yağdı');
      expect(ProfanityFilter.censor('çeşit çeşit oyunlar'), 'çeşit çeşit oyunlar');
      expect(ProfanityFilter.censor('klasik ve eksik şeyler'), 'klasik ve eksik şeyler');
    });

    test('Real profanities are still masked', () {
      expect(ProfanityFilter.censor('AMK'), 'A*K');
      expect(ProfanityFilter.censor('SİKERİM'), 'S*****M');
      expect(ProfanityFilter.censor('OROSPU'), 'O****U');
      expect(ProfanityFilter.censor('PİÇ'), 'P*Ç');
      expect(ProfanityFilter.censor('orospu çocuğu'), 'o****u çocuğu');
      expect(ProfanityFilter.censor('orospuçocuğu'), 'o**********u');
    });
  });
}
