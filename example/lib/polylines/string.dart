import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:power_geojson/power_geojson.dart';

class StringGeoJSONLines extends StatelessWidget {
  const StringGeoJSONLines({
    Key? key,
    MapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolylines.string(
      stringLines,
      bufferOptions: BufferOptions(
        buffer: 70,
        // buffersOnly: true,
        polygonBufferProperties: PolygonProperties(
          fillColor: const Color(0xFF54A805).withOpacity(0.5),
          borderStokeWidth: 0.3,
          label: 'Buffer Line',
          isDotted: false,
          borderColor: Colors.green,
        ),
      ),
      polylineLayerProperties: const PolylineProperties(),
      mapController: _mapController,
    );
  }
}

class StringGeoJSONMultiLines extends StatelessWidget {
  const StringGeoJSONMultiLines({
    Key? key,
    MapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolylines.string(
      stringMultiLines,
      bufferOptions: BufferOptions(
        buffer: 70,
        polygonBufferProperties: PolygonProperties(
          fillColor: const Color(0xFF3E05A8).withOpacity(0.5),
          borderStokeWidth: 0.3,
          isDotted: false,
          labelStyle: const TextStyle(fontSize: 7),
          borderColor: Colors.green,
          layerProperties: {
            LayerPolygonIndexes.label: 'color',
            LayerPolygonIndexes.fillColor: 'color',
          },
        ),
      ),
      polylineLayerProperties: const PolylineProperties(),
      mapController: _mapController,
    );
  }
}

const stringLines =
    '''{"type":"FeatureCollection","features":[{"type":"Feature","id":0,"geometry":{"type":"LineString","coordinates":[[-2.5219806586537823,34.851120472523853],[-2.521812188035562,34.838822117393732],[-2.5165895988707172,34.838485176157292],[-2.516758069488938,34.851457413760301],[-2.5079975973414568,34.850783531287412],[-2.5083345385778983,34.839664470484841],[-2.5005848901397414,34.839327529248393],[-2.5007533607579626,34.85095200190564],[-2.4916559473740394,34.851120472523853],[-2.4914874767558191,34.838148234920851],[-2.4837378283176621,34.83747435244797],[-2.4832324164630002,34.850109648814531]]},"properties":{"FID":0,"Id":0}},{"type":"Feature","id":1,"geometry":{"type":"LineString","coordinates":[[-2.5191166581440294,34.842696941612814],[-2.5187797169075874,34.854826826124707],[-2.5058142181293146,34.8524614986449],[-2.5055985757379924,34.841571557883114],[-2.5027952246507983,34.841571557883114],[-2.5024717610638141,34.852353677449244],[-2.4901801447584253,34.853108425818874],[-2.4898566811714407,34.839307312774224],[-2.4858672969319726,34.839199491578569],[-2.486406402910279,34.852569319840569],[-2.4814466279098593,34.8524614986449],[-2.4809075219315524,34.834563180165119],[-2.4936304230195869,34.836503961687029],[-2.4933069594326032,34.849226862775062],[-2.4990214828026525,34.849334683970724],[-2.4992371251939747,34.837582173643646],[-2.5102348871514284,34.837797816034964],[-2.5095879599774609,34.849226862775062],[-2.5147633773692033,34.849334683970724],[-2.5147633773692033,34.836827425274016],[-2.5245751061743822,34.837905637230627],[-2.5245751061743822,34.853324068210199],[-2.5259767817179792,34.854186637775484]]},"properties":{"FID":1,"Id":0}}]}''';
const stringMultiLines =
    '''{"type":"FeatureCollection","features":[{"type":"Feature","id":0,"geometry":{"type":"MultiLineString","coordinates":[[[-2.4195505227755278,34.845055530268013],[-2.4101161681551462,34.846740236450096],[-2.4158441691746502,34.852131296233182]],[[-2.4704286494781864,34.858027767870894],[-2.4618366479489309,34.843707765322137]],[[-2.4241107312667491,34.862492990174076],[-2.423861608865892,34.862338058508996],[-2.423524682135421,34.86212409351819],[-2.4232113132393893,34.861920288081549],[-2.4229193176972434,34.861725216374133],[-2.4227587931848324,34.861615429788543],[-2.4226047282544658,34.861508083355339],[-2.4224569427617784,34.861403051507978],[-2.4223153012894869,34.861300237939645],[-2.4221796607093928,34.861199538085359],[-2.42204995740508,34.861100904004829],[-2.4219261114592343,34.861004274898647],[-2.4218080600608412,34.860909601726462],[-2.4216956548879232,34.860816762090387],[-2.4215889544151046,34.860725800656176],[-2.4214879195749699,34.860636684102772],[-2.4213925189669783,34.860549384713948],[-2.4213027207218278,34.860463873074991],[-2.4212185070807717,34.860380132005858],[-2.4211398582860575,34.860298141847466],[-2.4210667583395287,34.860217885907772],[-2.4209720566692239,34.860108203483136],[-2.420875649653619,34.859991018238176],[-2.4207765250721396,34.859865106729693],[-2.4206727355007258,34.859727998672952],[-2.4205837352621655,34.859606775215084],[-2.4204858987291868,34.859470457201276],[-2.4201669885243291,34.859016644291628],[-2.4200487044863905,34.858850309444598],[-2.4199310266096932,34.85868891186216],[-2.419822625257888,34.858545226054623],[-2.4197086060127075,34.858400389560558],[-2.4195982040921757,34.858267101567677],[-2.4194896770480985,34.858143262048436],[-2.4193820521573195,34.858027767870894],[-2.4193278725007188,34.857973703874961],[-2.4192673837271825,34.857917528124318],[-2.4192004994760947,34.857859160216776],[-2.4191270948506101,34.857798491021498],[-2.4190470955129459,34.857735454365269],[-2.4189602034541147,34.857669811166303],[-2.4188661302671073,34.857601343008298],[-2.4187644111582478,34.857529711275852],[-2.4185696654790299,34.857397768188058],[-2.4183434937879826,34.857250468321176],[-2.418116565602749,34.857106614295532],[-2.4175935044533121,34.856779270180937],[-2.4173520854869794,34.856624408269369],[-2.4172337876028944,34.856545720906269],[-2.4171315183435786,34.856475093168989],[-2.4170430840171564,34.85641100805293],[-2.4169674182810086,34.856352688346703],[-2.4169240880164256,34.8563170601536],[-2.4168858436409084,34.856283569600791],[-2.4168525717853111,34.856252117290325],[-2.416824192265838,34.856222627248144],[-2.4168006329710581,34.856195022478005],[-2.4167818626666167,34.856169263866803],[-2.4167678484950974,34.856145306210792],[-2.4167585694102973,34.856123113350364],[-2.4167540080313188,34.85610261575485],[-2.4167541812960383,34.8560838324548],[-2.4167590894722877,34.856066741151409],[-2.4167687378184275,34.856051323808664],[-2.4167831380564913,34.85603756340015],[-2.4168023024645926,34.856025449344322],[-2.4168262477479376,34.856014971118697],[-2.4168549928840264,34.856006120452307],[-2.41689306508112,34.85599731434462],[-2.4169344845160889,34.855989682384724],[-2.4169792511889767,34.855983224572611],[-2.41702736510012,34.855977940907906],[-2.4170788262490133,34.855973831391154],[-2.4171336346359507,34.855970896021944],[-2.4172532931237072,34.855968547726448],[-2.4173863405633051,34.855970896021944],[-2.417532776954745,34.855977940907906],[-2.4176926022981107,34.855989682384724],[-2.417865816593276,34.856006120452307]],[[-2.4241107312667491,34.862492990174076],[-2.4241143848365239,34.862506561270848],[-2.424137506709509,34.862586292492438],[-2.4241619793217652,34.86266488565451],[-2.4241878060891926,34.862742351719902],[-2.4242149907988217,34.862818701961928],[-2.424243536620021,34.862893945199509],[-2.4242734470527578,34.862968090654661],[-2.4243047255272172,34.863041146826092],[-2.4243373779362845,34.863113127011161],[-2.424371405487598,34.863184033424517],[-2.4244068116451558,34.863253873281906],[-2.4244435997974292,34.863322653264731],[-2.4244817736144162,34.863390380198695],[-2.4245213362271945,34.863457059604343],[-2.4245622910253752,34.863522697192792],[-2.4246046413221141,34.863587298272279],[-2.4247944051397869,34.863869434134315],[-2.4248600518896866,34.863964390342268],[-2.4249205954304855,34.864049614297741],[-2.4249821652472594,34.864133459347826],[-2.4250414498380497,34.864211114298115],[-2.4250992022782687,34.864283564229098],[-2.4251558248493073,34.864351311206306],[-2.4252144709921879,34.864417866907417],[-2.4252724709456874,34.864479931610092],[-2.4253300266600033,34.864537721069986],[-2.4253872783171233,34.864591375534346],[-2.4254443855700645,34.864641040633025],[-2.4255014014921072,34.864686758451967],[-2.4255584070320868,34.864728593784179],[-2.4256154650314903,34.864766592599736],[-2.4256506617047733,34.864787937945266],[-2.4256875904313393,34.864808574893573],[-2.4257262499404897,34.864828502735186],[-2.4257666389751362,34.864847720822141],[-2.4258526002669569,34.864884025261858],[-2.4259454654730725,34.86491748449447],[-2.4260452159338177,34.864948092694654],[-2.4261518607974546,34.864975853483017],[-2.4262654052136372,34.865000768340948],[-2.4263858803695113,34.86502284418895],[-2.4265098639602187,34.865041616372324],[-2.4266405912234958,34.86505772688286],[-2.4267782478584721,34.865071199788069],[-2.4269233532088448,34.865082086436274],[-2.4270687166043476,34.865090086953217],[-2.4272239701367151,34.865095950891629],[-2.4273773484335868,34.865099600830199],[-2.4276371124501583,34.865103533836233],[-2.4277081454835061,34.865103073458741],[-2.4277689395375992,34.86509877546851],[-2.4277955177831592,34.8650951861121],[-2.4278195607696142,34.865090635232555],[-2.4278410755256798,34.865085121501693],[-2.4278600685987559,34.865078643243251],[-2.4278765437375811,34.865071199565548],[-2.4278905091095737,34.865062787223991],[-2.4279019693166752,34.86505340345056],[-2.4279109283114684,34.86504304501392],[-2.4279173891439232,34.865031708511282],[-2.4279213544075482,34.865019389562931],[-2.4279228256031322,34.865006083525927],[-2.4279218033201442,34.864991785117603],[-2.4279182968944628,34.864976520862726],[-2.4279123052857763,34.864960255980904],[-2.427903825873865,34.864942983342374],[-2.4278928547186149,34.864924694909298],[-2.4278793871201141,34.864905382665228],[-2.4278634158689645,34.864885036124079],[-2.4278239269358615,34.864841196135998],[-2.4277743232862874,34.864793098454072],[-2.427714461822096,34.864740600596882],[-2.4276441765948533,34.864683556730057],[-2.4275632339213651,34.864621776990674],[-2.4274241858659407,34.864521825382894],[-2.4272600286677872,34.864410125804866],[-2.4270688156678846,34.864285348405716],[-2.4268468641483034,34.864145087435759],[-2.4266136685170325,34.864001135746221],[-2.4263406639832326,34.863835424000207],[-2.4249252964739165,34.862989658453543],[-2.4245576322753211,34.862767554977232],[-2.424226812567253,34.862565182273528],[-2.4241107312667491,34.862492990174076]],[[-2.4298272304869508,34.863081886417525],[-2.4299502674925844,34.862833123170873],[-2.4300682351069209,34.862583233444155],[-2.4301811333300454,34.862332217237274],[-2.4302889621620842,34.862080074549894],[-2.4303917216028692,34.861826805382393],[-2.4304894116524838,34.861572409734777],[-2.4305820323108862,34.861316887606918],[-2.4306695835780765,34.861060238998903],[-2.4306997295402284,34.860964733013567],[-2.4307276052133608,34.860867490880914],[-2.4307532233569868,34.86076846815191],[-2.430776597118105,34.860667614067424],[-2.4307977374698551,34.860564882799352],[-2.4308166593626828,34.860460203363786],[-2.4308333750357356,34.860353508204781],[-2.4308478968766773,34.86024471840463],[-2.4308602205240124,34.860133905945517],[-2.4308703791759401,34.860020818502925],[-2.4308783827799116,34.859905345888741],[-2.4308842406041813,34.859787354966642],[-2.4308879591893864,34.859666736379403],[-2.4308895463014708,34.85954327307693],[-2.430889004644381,34.859416762833334],[-2.4308863331927677,34.859286947302046],[-2.4308774658085404,34.859068811059331],[-2.4308629160847328,34.858839434457352],[-2.4308425433671719,34.858596504090542],[-2.4308159657376667,34.858335431114384],[-2.4307892162744094,34.858104270985109],[-2.43075672060165,34.857846425918524],[-2.4306397190733398,34.85698357681995],[-2.4305979258717487,34.856661820881058],[-2.4305603943706808,34.856342596775484],[-2.4305450715598633,34.856196516885277],[-2.4305317918760245,34.856057113756755],[-2.430518792118634,34.855902099417719],[-2.4305083090765294,34.85575343103325],[-2.4305002796984208,34.855610209844073],[-2.4304946704842516,34.855471829513533],[-2.4304914584732558,34.855337627723756],[-2.4304906424298576,34.855207382344055],[-2.4304922204027237,34.855080763217067],[-2.430496195711644,34.854957516416221],[-2.4305036687790862,34.854820731628998],[-2.4305142868660772,34.854687777473238],[-2.4305280688095015,34.854558419379401],[-2.4305450347322832,34.854432469707717],[-2.4305652128709196,34.854309729394174],[-2.4305886223843536,34.854190090871271],[-2.4306152881014236,34.854073427534438],[-2.4306452343264162,34.853959633349163],[-2.4306785284323897,34.853848479967453],[-2.4307151615472398,34.853740021956426],[-2.4307551596188559,34.853634182597325],[-2.4307985476710865,34.853530895783337],[-2.4308453550753288,34.853430092837698],[-2.4308956035971367,34.853331728047664],[-2.430949318680347,34.853235751652022],[-2.4310065248144932,34.853142119942561],[-2.4310422390953104,34.853087687926745],[-2.431080128361633,34.853033012108469],[-2.4311202539619785,34.852978003827857],[-2.4311626961493311,34.85292255296774],[-2.4312075141250178,34.852866579119826],[-2.4312548646504943,34.852809883649115],[-2.431304896826429,34.852752287708562],[-2.431357824249313,34.852693545191933],[-2.4314148917979477,34.852632327044994],[-2.4314756498231418,34.852569165746189],[-2.4316108799903513,34.852434289996509],[-2.4317590008395928,34.852292606707039],[-2.4320621555174564,34.852009530787626],[-2.4321894974606826,34.851888940327925],[-2.4323205298804687,34.851761014452741],[-2.4324347511334112,34.851644433330961],[-2.4325000720943311,34.85157481604103],[-2.4325612991689081,34.851507077064333],[-2.4326188625998437,34.851440739890023],[-2.4326730354393513,34.851375489022374],[-2.4327241077771786,34.851310968768018],[-2.4327721613599129,34.85124706906069],[-2.4328173273580074,34.85118361528454],[-2.4328597016149951,34.851120472523846],[-2.4328920254509594,34.851069390157591],[-2.4329233872167499,34.851016987029155],[-2.4329538016648868,34.850963238507347],[-2.4329832848395929,34.850908116255823],[-2.433011850715332,34.850851594571679],[-2.433039519798498,34.850793633313998],[-2.4330663104794032,34.850734193995848],[-2.4330922431701061,34.85067323136262],[-2.4331173029768802,34.85061078820101],[-2.4331415517703006,34.85054671836469],[-2.4331877173675789,34.850413427502133],[-2.4332309564669847,34.850272738201724],[-2.4332715677818095,34.850123681702506],[-2.4333024658539557,34.849997271914148],[-2.4333321604597904,34.849863595770714],[-2.4333609596321684,34.849721282521543],[-2.4333894199159891,34.849567590244035],[-2.4334127428073979,34.849431996583768],[-2.4334373755660303,34.849280277717213],[-2.4335146858435031,34.848776587537571],[-2.4335440263348507,34.848591519501923],[-2.4335747041522433,34.848410412634422],[-2.433604576229941,34.848248606908484],[-2.4336386950325677,34.848081665685804],[-2.433674096775122,34.847927126970475],[-2.4337113670010391,34.847782444214232],[-2.4337508557316507,34.847646275519011],[-2.4337956006857295,34.847509706428937],[-2.433819127581077,34.847444321688585],[-2.4338434646391951,34.847380755584282],[-2.4338686451115787,34.847318922512407],[-2.4338946890152355,34.847258774535234],[-2.4339216203913532,34.847200256175213],[-2.433949460767364,34.847143320706664],[-2.4339782604158997,34.847087870522486],[-2.4340080110206843,34.847033926675387],[-2.4340387312904546,34.846981455265961],[-2.4340704383739027,34.846930427028553],[-2.4341031512412599,34.846880811739446],[-2.4341368834944221,34.846832589067475],[-2.4341716504983291,34.846785737060159],[-2.4342074665607463,34.846740236450096],[-2.4342592774351153,34.846677865555336],[-2.4343132538685386,34.846615896844284],[-2.4343694105710592,34.846554313418387],[-2.4344277646676171,34.846493096488558],[-2.4344883319420827,34.846432229295146],[-2.4345511369800588,34.846371686937943],[-2.4346162037075603,34.84631144633795],[-2.4346835603424872,34.846251481357726],[-2.4347531845777444,34.846191809229992],[-2.4348251629017579,34.8461323532931],[-2.4348995357279142,34.846073080141295],[-2.4349763517464429,34.846013950950606],[-2.4350556526545306,34.845954933136852],[-2.435137515662249,34.84589596877035],[-2.4352220140403578,34.845837005034141],[-2.4353092392185713,34.845777978094446],[-2.435483787143832,34.845664811403722],[-2.4356696650452507,34.845550508293371],[-2.4358681877615167,34.845434255808136],[-2.4360818621655764,34.845314583702248],[-2.4363009634561985,34.845196518868782],[-2.4365444677164723,34.845069464501044],[-2.4368067650043823,34.844935943100147],[-2.4372399376887062,34.844718589031515],[-2.4373365164383602,34.844671775255016],[-2.437436519142306,34.844626604223578],[-2.4375401542284472,34.8445829815645],[-2.437647698597817,34.844540790555392],[-2.4377593282171812,34.844499956108621],[-2.4378756274254627,34.844460258750615],[-2.437997132545906,34.844421514656993],[-2.4381246672397574,34.844383460709466],[-2.4382330505835799,34.844352943367994],[-2.4383469964636642,34.844322411949101],[-2.4385973540619701,34.84425978035614],[-2.4388406814197747,34.844202983938317],[-2.4394382406071289,34.844068096245721],[-2.439601953144547,34.844029487776311],[-2.439748594030454,34.843993343472405],[-2.4399057253080976,34.843952413092495],[-2.4400517382990357,34.843911798403063],[-2.4401891853116995,34.843870787886829],[-2.4403193938987293,34.843828982254671],[-2.4404607580198219,34.843779770109627],[-2.4405950111766814,34.843728732645516],[-2.4407229345930528,34.843675572198094],[-2.4408450517073939,34.84362007020782],[-2.4409619247049132,34.843561962810647],[-2.4410737401121203,34.843501148383126],[-2.4411807731527206,34.843437476974891],[-2.4412832325260005,34.84337082408576],[-2.4413576513205193,34.843318360840584],[-2.4414318694041777,34.843262349194049],[-2.441506015681643,34.843202692055861],[-2.4415802512467888,34.843139259963777],[-2.4416546889366444,34.843071961708716],[-2.4417296271386797,34.843000532626334],[-2.4418053307269965,34.842924720877107],[-2.441882171671784,34.842844154397682],[-2.441956015531852,34.842763471690446],[-2.4420318289307277,34.842677537670504],[-2.4421103085955944,34.842585565594661],[-2.4421927419928791,34.84248604819205],[-2.4423557929652833,34.842282338043319],[-2.4426695615145828,34.841879401322856],[-2.4428002848004264,34.841714019533867],[-2.442938689514667,34.841544519303625],[-2.4430652792835295,34.841396624380302],[-2.4431409979944387,34.84131210631891],[-2.4432148980420001,34.841232788434993],[-2.4432875038887123,34.841158108440851],[-2.4433591653723066,34.841087707471615],[-2.4434302782820989,34.841021203751332],[-2.4435009679454032,34.840958487322091],[-2.4435714312049854,34.84089938373635],[-2.4436418211811275,34.840843764812384],[-2.4437388857837208,34.840772071631761],[-2.4438387387401752,34.840703526649563],[-2.4439414201060621,34.840638102344926],[-2.4440469754347851,34.840575769671858],[-2.4441554469440252,34.840516503230845],[-2.444266897092052,34.840460268442698],[-2.4443813863314916,34.840407034769527],[-2.4444989845380829,34.840356769691454],[-2.4446196502539856,34.840309484720407],[-2.4447435825866104,34.840265095795047],[-2.4448708773638526,34.840223568537752],[-2.4450016480532515,34.840184865885611],[-2.4451359930350876,34.840148957554007],[-2.4452740861968962,34.840115795939951],[-2.4454160924208921,34.840085341348541],[-2.4455622145210429,34.840057550204349],[-2.4457062534211884,34.840033386763778],[-2.445854526968569,34.84001158547224],[-2.4460073164973961,34.839992104788209],[-2.4461649868640651,34.839974898059268],[-2.4463277882273928,34.839959933445698],[-2.446496444290422,34.839947140105153],[-2.446671619941803,34.839936467067638],[-2.4468542903754615,34.839927854561751],[-2.4470246238767914,34.839921861275862],[-2.4472032444663689,34.839917414984825],[-2.4473918542729995,34.839914471478664],[-2.4475936894435391,34.839912979333491],[-2.4479936738874737,34.83991373615811],[-2.4487674463140356,34.839920838248759],[-2.4490853040755054,34.83992254616529],[-2.4494146939141741,34.839921598856471],[-2.4497089866416122,34.839917244153085],[-2.4498795531184094,34.839912759402317],[-2.4500428838988357,34.839906861687695],[-2.4502000990435446,34.839899510254192],[-2.4503519309549029,34.839890670364326],[-2.4504991844587076,34.839880291492008],[-2.4506421038566897,34.839868352561908],[-2.4507810742244063,34.839854821300712],[-2.4509163875109703,34.839839669139934],[-2.4510807417015501,34.839818410230748],[-2.4512401790435634,34.839794523433611],[-2.4513950389236614,34.839767957767009],[-2.4515455851034873,34.839738667807417],[-2.4516920991024582,34.839706596976015],[-2.4518347209657092,34.839671712738884],[-2.4519736212162275,34.839633973318911],[-2.4521089400477925,34.839593340541228],[-2.452240995848654,34.839549710022794],[-2.4523696951865386,34.839503103609843],[-2.4524951365593499,34.839453485592529],[-2.4526174036920589,34.839400822805246],[-2.4527365838606157,34.8393450770577],[-2.4528527329152388,34.839286221607253],[-2.4529659124042329,34.839224225238787],[-2.4530761758014243,34.839159058630173],[-2.4532093319287687,34.83908053181306],[-2.453364772604588,34.838994814644231],[-2.4535267022148295,34.838909602362349],[-2.4539861985361924,34.838672873232326],[-2.454124968246429,34.838598671907306],[-2.4542476166792029,34.838530448534542],[-2.4543820028993544,34.83845166797758],[-2.4545034469724185,34.838375560476223],[-2.4546140744432994,34.838300790799394],[-2.4547149009875247,34.838226665566864],[-2.4547714065255475,34.838181945981944],[-2.454824719402767,34.838137172297415],[-2.4548749337359377,34.838092265379565],[-2.4549221203236127,34.838047161789788],[-2.4549663516512257,34.838001790927109],[-2.4550076616457939,34.837956116570204],[-2.4550460909692218,34.837910093707428],[-2.4550816714108463,34.837863684198481],[-2.4551144691425115,34.837816794086507],[-2.4551444601992336,34.837769449317562],[-2.4551716632241964,34.837721620421114],[-2.4551960928818817,34.837673281562999],[-2.4552177630661527,34.837624404567237],[-2.4552366816010256,34.837574971009545],[-2.4552528565014677,34.837524959909743],[-2.4552662938383434,34.837474352448048],[-2.4552782728098155,34.837419289008302],[-2.4552887920493287,34.837361330187875],[-2.4552978003660018,34.837300757306494],[-2.4553052483288687,34.837237901898376],[-2.4553110964222942,34.837173081061692],[-2.4553153019805043,34.837106746747793],[-2.4553178372834372,34.837039334957396],[-2.4553186844062469,34.836971319826361],[-2.4553178334497048,34.83690303890225],[-2.4553152869292978,34.836835152492498],[-2.4553110639679177,34.836768169785643],[-2.4553051960251073,34.836702589844307],[-2.4552977293893017,34.836638918399096],[-2.4552887148150395,34.83657757935903],[-2.4552782141223877,34.836518992604965],[-2.4552662938383434,34.836463528738676],[-2.4552488020739993,34.836399641128097],[-2.4552267343003029,34.836337720336246],[-2.4552000834892591,34.836277746571241],[-2.4551688400139109,34.836219698116729],[-2.4551329943814508,34.836163556271885],[-2.455092529092302,34.836109292708144],[-2.4550474253948718,34.836056882212119],[-2.4549976590827587,34.836006296603429],[-2.4549432639868263,34.835957559397102],[-2.4548841516000302,34.835910581369411],[-2.4548202793820799,34.835865328622788],[-2.4547515924334657,34.835821762192154],[-2.4546780450955019,34.835779851302021],[-2.4545995381157688,34.835739537717828],[-2.4545159742736962,34.835700771360635],[-2.4544272236955647,34.835663491864352],[-2.4543474701698029,34.835632879671849],[-2.4542637194716805,34.835603249139446],[-2.4541758242741816,34.835574547990504],[-2.4540835834707604,34.835546710444177],[-2.4539868753516085,34.835519695710886],[-2.4538852542370226,34.835493375496128],[-2.4537783080063584,34.835467642554335],[-2.4536653887791688,34.835442340680167],[-2.4534658615281795,34.835401438672221],[-2.4532402481359039,34.835359573106203],[-2.4530220031627605,34.835321966956656],[-2.4525237096026018,34.83523919936929],[-2.452291596563835,34.835198232782005],[-2.4520791177968304,34.835156638370322],[-2.4519847853819474,34.835136231086324],[-2.451896881473882,34.835115763792928],[-2.4517505652549461,34.835082063811427],[-2.4516004398054871,34.83505085874323],[-2.451446185713599,34.835022081955714],[-2.4512873816670089,34.834995654672468],[-2.4511237616502912,34.834971526069893],[-2.4509544435308745,34.834949559823528],[-2.4507786256377919,34.834929651091798],[-2.4505950793129636,34.834911660216861],[-2.4504466251429897,34.834898946159157],[-2.4502914031561742,34.834887186917207],[-2.4501279274590635,34.834876268343734],[-2.4499533573422174,34.834865999922165],[-2.4496121031364599,34.834848994158818],[-2.4487034489093871,34.83480918117678],[-2.4484328033715652,34.834794570293639],[-2.4481905278730887,34.834778822556423],[-2.447825281180767,34.834750857776335],[-2.4474424762739417,34.834717826525377],[-2.4470384215550594,34.834679414014005],[-2.4466061190045219,34.834634956833042],[-2.4462008677549747,34.834590749758618],[-2.4457499576608437,34.834539391735433],[-2.4440835630316911,34.834341906773226],[-2.4433940049986287,34.834262688656054],[-2.4430238225138838,34.834222164069971],[-2.4426779623286934,34.834186023580983],[-2.4423498535017378,34.834153581713878],[-2.4420361649612561,34.834124511504399],[-2.4416641948790927,34.834092858482215],[-2.4413071796540868,34.834065731938125],[-2.4409627141651371,34.834042949747641],[-2.440629223705491,34.834024408737896],[-2.4403049714945664,34.834010019626561],[-2.4399894313685295,34.833999766695925],[-2.4396817712351524,34.833993623116726],[-2.439381359400052,34.833991576553856],[-2.4392028084095463,34.833992326318736],[-2.4390266071608817,34.833994576042016],[-2.4388526593263373,34.833998326962842],[-2.4386808803706788,34.834003580914938],[-2.4385111814584626,34.834010340752187],[-2.4383435015857149,34.834018609044293],[-2.4381777741287376,34.834028389082732],[-2.4380139395721305,34.834039684386745],[-2.4378518886100222,34.834052503307682],[-2.4376916244906912,34.834066846413918],[-2.4375330988766506,34.834082718035859],[-2.4373762680114788,34.834100122559462],[-2.4372210863864021,34.834119065101916],[-2.4370675198809577,34.834139549896463],[-2.4369155321886082,34.834161581789104],[-2.4367650901048146,34.834185165596786],[-2.4366159588828675,34.834210341809907],[-2.4364683162824976,34.834237084149066],[-2.4363221341590067,34.834265397714738],[-2.436177386562858,34.834295287535497],[-2.4360340467013275,34.83432675918273],[-2.435892093384469,34.834359817348044],[-2.4357515043988873,34.834394467206387],[-2.4356122591270317,34.834430713841428],[-2.4354743254131268,34.834468565886596],[-2.4353376972725744,34.834508025249619],[-2.4352023568484036,34.834549097089479],[-2.435068287474758,34.834591786465467],[-2.4349354720386582,34.834636098851092],[-2.4348038965076544,34.834682038953133],[-2.4346735463135021,34.834729611859501],[-2.4345444077971625,34.834778822556423],[-2.4342592796529297,34.834890762821331],[-2.4339927234623566,34.834997417546838],[-2.4337394310554812,34.835100912127956],[-2.4334970532487832,34.83520220990151],[-2.4332628243052143,34.83530248196341],[-2.4330367021552339,34.835401762544819],[-2.4328178268350324,34.835500429493159],[-2.4326056386176198,34.835598735548388],[-2.4323978914607407,34.835697757494216],[-2.4321961325642292,34.835796795326488],[-2.4320000719295018,34.835895991493032],[-2.4318094963352106,34.835995454001456],[-2.4316241741601448,34.836095304970016],[-2.4314440118464624,34.836195596093816],[-2.431268884206915,34.836296397104562],[-2.4310986933952416,34.836397764375505],[-2.4309313032981716,34.836501036667357],[-2.4307688135689736,34.836604987311809],[-2.4306111597157116,34.836709657591591],[-2.4304582896717735,34.836815082105517],[-2.4303101484714613,34.836921299117222],[-2.430166706456399,34.837028330264175],[-2.4300279290389248,34.837136201369475],[-2.4298937876834747,34.837244934632139],[-2.429764219708535,34.837354582880472],[-2.4296392431393317,34.837465132953753],[-2.4295188384906776,34.837576602098295],[-2.4294029894779046,34.83768900540251],[-2.4292916792993156,34.837802359326162],[-2.4291848977561497,34.837916674421308],[-2.4290826336069706,34.838031962729879],[-2.4289848773959095,34.838148234920922],[-2.4288959195225344,34.838259837730831],[-2.4288085848475807,34.83837513675121],[-2.4287228591115069,34.838494150794503],[-2.4286387266304001,34.838616901623027],[-2.4285561735419257,34.838743409187529],[-2.4284751795278532,34.838873704345957],[-2.4283957260606357,34.839007816881605],[-2.4283177924814718,34.839145781644831],[-2.4282413902859386,34.839287573985189],[-2.4281664611495799,34.8394332977646],[-2.4280929799803745,34.839583001741559],[-2.4280209182652843,34.839736743969098],[-2.4279502519789724,34.839894574764472],[-2.4278809407333259,34.84005658338269],[-2.4278129483763298,34.840222854241119],[-2.4277462326695503,34.840393490557567],[-2.4276819809299628,34.840565239486423],[-2.4276188643714649,34.840741434260934],[-2.4275568292163037,34.84092222482461],[-2.4274958100897948,34.841107801550251],[-2.4274357586839113,34.841298306612892],[-2.4273765632243363,34.841494089848581],[-2.4273181262758765,34.841695472982543],[-2.427260320205197,34.841902895454069],[-2.4272038400811295,34.842113680198068],[-2.427147642014428,34.842331539678916],[-2.4270915048976009,34.842557328831532],[-2.4270350902081477,34.842792407801603],[-2.4269784686515115,34.843036373826678],[-2.4269204396453778,34.843294296191999],[-2.4268600760982686,34.843570263108994],[-2.4267947593590327,34.843876235940385],[-2.4267632305080067,34.844034147122898],[-2.4267346021402281,34.844195717209871],[-2.4267088226612259,34.844361236298198],[-2.4266858339415989,34.844531076663692],[-2.4266655958245922,34.844705498258051],[-2.4266480198734479,34.844885222266228],[-2.4266330410184671,34.845070908135995],[-2.4266205821377431,34.845263507055421],[-2.4266112210029354,34.845449143948059],[-2.4266038848228813,34.845643155203376],[-2.4265985030393891,34.845847344456971],[-2.426594984975444,34.846065106900213],[-2.426593363043283,34.846271946421098],[-2.4265930538337281,34.846501537582199],[-2.4265972585839997,34.847353534530455],[-2.4265972136875202,34.847706387632968],[-2.4265931356082096,34.848073896794517],[-2.4265893248618524,34.848242102596146],[-2.4265842745943771,34.84840283008284],[-2.4265761668057859,34.848594986966575],[-2.4265659892500264,34.848779295868368],[-2.4265536702973622,34.848957045351639],[-2.4265391507804894,34.849129078341861],[-2.4265223467042785,34.84929632404355],[-2.4265032238617503,34.849459064755941],[-2.4264817297064569,34.849617746308198],[-2.4264578181225316,34.849772707578097],[-2.4264259993722455,34.849954965375645],[-2.4263898276049929,34.850140371754762],[-2.4263492251786283,34.850329326104713],[-2.4263040800120308,34.850522350991696],[-2.4262543226561286,34.850719776234243],[-2.4261996878518697,34.850922683569024],[-2.4261399143694118,34.851132046887244],[-2.4260745789601534,34.851349350893088],[-2.4260181490506456,34.851529479780766],[-2.4259573372485423,34.851717415985306],[-2.42589151110072,34.851915121384053],[-2.42581938293264,34.852126466843615],[-2.4256829472675667,34.852515949654887],[-2.4253530308752538,34.853441760543127],[-2.4252675647473563,34.853686499347177],[-2.4251919139374793,34.853907738726157],[-2.4251160259320579,34.854135747670099],[-2.4250468483353695,34.854350658937108],[-2.4249832845115549,34.854555883341945],[-2.424924765693306,34.854753265179113],[-2.4248705039990393,34.854945556504447],[-2.4248206313921408,34.855132393677252],[-2.424774926420997,34.855314607483258],[-2.4247332407853115,34.855492790934221],[-2.4246954257683959,34.855667595893252],[-2.4246614304854086,34.855839275711404],[-2.4246311855677498,34.856008181312504],[-2.4246046413221141,34.856174591070562],[-2.4245800110638376,34.856334522726677],[-2.4245526171604213,34.856503299141707],[-2.4244879918592828,34.85687678276782],[-2.4244224759565505,34.857235052294484],[-2.4242594005886522,34.858105933302291],[-2.4241800680419869,34.858547179963196],[-2.4241446061231775,34.858754662106577],[-2.4241125836944351,34.858950368817858],[-2.4240835504064906,34.859137056617129],[-2.4240572749551634,34.859316221267875],[-2.4240257796061373,34.859548982075893],[-2.4239987715160973,34.859772002396895],[-2.4239760777986392,34.859986714724201],[-2.4239576018318765,34.860194042100368],[-2.4239432598132824,34.860395002485348],[-2.4239330384129354,34.860589884576171],[-2.4239269129974312,34.860779161765478],[-2.4239248723673859,34.860963188292196],[-2.4239274758797591,34.861165111884361],[-2.4239307313383476,34.861263821392484],[-2.4239352908054252,34.861361081685615],[-2.4239411562365518,34.861456932478461],[-2.4239483293987867,34.861551401086103],[-2.4239568125537305,34.861644517235945],[-2.4239666081202094,34.861736307424543],[-2.4239777218339249,34.861826820054063],[-2.4239901540858284,34.861916053592807],[-2.4240039078496443,34.862004029361756],[-2.4240189861345152,34.86209076658777],[-2.4240353924529172,34.86217628519978],[-2.4240531297012717,34.862260600041921],[-2.4240722011968336,34.862343726871202],[-2.4240926102318365,34.862425680026433],[-2.4241107312667491,34.862492990174076]]]},"properties":{"FID":0,"Id":0}},{"type":"Feature","id":1,"geometry":{"type":"MultiLineString","coordinates":[[[-2.4562771175476774,34.852299766851431],[-2.4695862963870607,34.845897883358973]],[[-2.4562771175476774,34.852299766851431],[-2.4566140587840941,34.844550118413267]],[[-2.4562771175476774,34.852299766851431],[-2.4488644103459642,34.842696941612886]],[[-2.4562771175476774,34.852299766851431],[-2.44111476190775,34.851962825614933]],[[-2.4562771175476774,34.852299766851431],[-2.4655430015498085,34.857353885398062]],[[-2.4562771175476774,34.852299766851431],[-2.4529077051832586,34.860891768380647]],[[-2.4672277077320182,34.864429651363359],[-2.460825824239639,34.869315299291742],[-2.4574773916264983,34.865704240683556],[-2.4508500296104003,34.870761214983816],[-2.4442710262600045,34.863664797649477],[-2.4513083061475207,34.858294465868759]]]},"properties":{"FID":1,"Id":0}},{"type":"Feature","id":2,"geometry":{"type":"LineString","coordinates":[[-2.410116168155175,34.846740236450117],[-2.4146648748471362,34.839664470484841]]},"properties":{"FID":2,"Id":0}},{"type":"Feature","id":3,"geometry":{"type":"LineString","coordinates":[[-2.410116168155175,34.846740236450117],[-2.4047251083721095,34.843202353467476]]},"properties":{"FID":3,"Id":0}},{"type":"Feature","id":4,"geometry":{"type":"LineString","coordinates":[[-2.410116168155175,34.846740236450117],[-2.4023665197170185,34.852131296233182]]},"properties":{"FID":4,"Id":0}},{"type":"Feature","id":5,"geometry":{"type":"LineString","coordinates":[[-2.410116168155175,34.846740236450117],[-2.4084314619729672,34.852973649324284]]},"properties":{"FID":5,"Id":0}},{"type":"Feature","id":6,"geometry":{"type":"LineString","coordinates":[[-2.410116168155175,34.846740236450117],[-2.4074206382636421,34.839327529248408]]},"properties":{"FID":6,"Id":0}}]}''';