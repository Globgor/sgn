=head1 NAME

t/unit/mason/text/sentences_secretom_detail_1.t - secretom/detail templates, part 1 of 2: sentences appear in the user's language

=head1 DESCRIPTION

Renders components with SGN::Test::MasonText in English and with a test
translation. Components needing real data are compiled only.

=cut

use strict;
use warnings;
use utf8;

use lib 't/lib';
use Test::More;
use SGN::Test::MasonText qw( page_sentences_ok component_compiles_ok );

page_sentences_ok(
    '/secretom/detail/cell_wall.mas',
    'However, the term "plant cell wall" is also used more broadly to refer to the entire compartment outside the plasma membrane that forms a continuum throughout the plant, also termed the "apoplast", or apoplastic compartment.',
    'They consist mostly of polysaccharides, but also contain components such as lignin, structural lipids and proteins in specialized cell types.',
    'Green fluorescent protein that has diffused throughout the cell wall and apoplastic compartment surrounding an onion epidermal cell.',
    'Plant cell walls are typically considered as complex structural matrices that surround all plant cells.',
    'Plant {link}cell wall{end_link} model',
    'Scale bar represents 50 micrometers.',
);

page_sentences_ok(
    '/secretom/detail/cuticle.mas',
    'To identify new candidate proteins with a potential role in cuticle biosynthesis, and particularly those that are secreted to the apoplast, we are generating a more comprehensive inventory of proteins that are associated with the outermost surface tissues of plant organs, we are using a range of complementary protein fractionation strategies (1D gel-based and liquid chromatography) coupled with several sensitive mass spectrometry (MS) platforms.',
    'We are also characterizing a number of tomato fruit cuticle mutants and have developing a new 3D imaging technique using confocal scanning laser microscopy for visualizing the architecture, deposition patterns and micro-structure of plant cuticles.',
    'Although Arabidopsis research has greatly accelerated the discovery of new cuticle-related genes, its cuticle poses some experimental limitations since it is relatively thin, fragile and difficult to isolate in substantial quantities.',
    'Little is yet known about many key mechanisms of cuticle biogenesis, and experimental strategies to identify new proteins that associate with cutin and waxes could provide a valuable means to identify new candidates.',
    'It is continuous with the outer-periclinal polysaccharide cell wall of the epidermis and consists of organic soluble waxes embedded in, and layered on, a non-soluble polyester matrix of ω-substituted fatty acids.',
    'This has allowed 3-D cuticle modeling based on the reconstruction of serial optical sections and its use in the identification of several previously unreported features of the tomato fruit cuticle.',
);

page_sentences_ok(
    '/secretom/detail/functional_screens.mas',
    'To date we have identified both known cell wall localized proteins as well as a number of proteins whose presence in the apoplast is unexpected, based on functional annotation, or the absence of a predicted secretory signal peptide, suggesting alternative non-canonical secretion pathways, as have describe in yeast and mammalian cells.',
    'If yeast cells are streaked onto plates containing sucrose as the sole carbon source, they must secrete invertase to break down the sucrose in order to grow, and so an invertase-deficient yeast mutant will be unable to grow.',
    'We typically also confirm the localization of candidates of interest by transient expression as GFP fusion proteins in onion epidermal cells, coupled with staining using the FM-64 dye to co-stain for the plasma membrane,',
    'Briefly, this involves ligating cDNAs in frame at the 5’ end of the DNA sequence encoding a gene termed necrosis-inducing protein (NIP) that has been truncated to remove the native secretory signal peptide.',
    'We have also identified several proteins that show dual localization in the wall an intracellular compartments, and we are now characterizing some of the complexity in the secretory pathway.',
    'This system can also identify plasma membrane (PM)-spanning or PM-anchored proteins if the orientation of the fusion protein is such that the invertase component is external to the cell.',
);

page_sentences_ok(
    '/secretom/detail/glycoproteome.mas',
    'We are using affinity selection of glycoproteins using the lectin Concanavalin A, coupled with two-dimensional liquid chromatography (2-D LC) and matrix-assisted laser desorption/ionization mass spectrometry (2DLC-MALDI MS/MS) and electrospray ionization MS (ESI-MS) analysis, to identify extracellular and secretory pathway proteins, focusing on those expressed in ripe tomato fruit.',
    'Tomato has long served as model system for fleshy fruit development and ripening is an excellent system to study cell wall proteins as it is associated with dramatic changes in wall biology, including dramatic enzyme-mediated cell wall polysaccharide degradation, apoplastic sugar metabolism and extracellular defenses against microbial pathogens.',
    'The large-scale isolation and analysis of glycoproteins by lectin affinity chromatography, coupled with mass spectrometry (MS), has become a powerful tool to evaluate the glycoproteome of mammalian cells; however, is has rarely been used with plants glycoproteins.',
    'In spite of this, there are few published proteomic analyses of ripening tomato fruit and most of those are based on extraction of total proteins followed by 2-DE separation, since the wall proteome was not the major target.',
    'As with all eukaryotes, N-glycosylation in plant cells is a common post-translational modification for proteins traveling through the secretory pathway, many of which are destined for the cell wall.',
    'This enrichment strategy has been highly effective, with a high proportion the identified proteins showing predicted localization either in the secretory pathway.',
);

page_sentences_ok(
    '/secretom/detail/phytophthora_interaction.mas',
    'Subsequently, in the second stage, hemibiotrophs orchestrate a physiological switch from asymptomatic infection to large-scale necrosis and tissue dissolution, presumably resulting from the coordinated secretion of factors such as lytic enzymes and necrosis elicitors.',
    'Hemibiotrophic pathogens, such as the bacterium {species}, the fungus {species2} and the oomycete {species3}, employ elements of both these strategies in a biphasic "stealth" infection mechanism.',
    'Biotrophic pathogens penetrate the plant wall, parasitize host cells while evading or suppressing defense responses and require viable host tissue for pathogen nutrition and reproduction.',
    'This involves an initial biotrophic phase, when the pathogen proliferates asymptomatically in the host and efficient mechanisms must be employed to evade and suppress host defenses.',
    'In contrast, necrotrophs, overwhelm plants by secreting mixtures of degradative enzymes that allow the pathogens to subsist on necrotized host tissue.',
    'These samples correspond to a time course experiment of a compatible interaction between {species} (clonal lineage US11) and its host tomato (M82).',
);

page_sentences_ok(
    '/secretom/detail/prediction.mas',
    'This will provide you with a list of predicted proteins, grouped by species, with the annotation protein length, molecular weight, confidence scores for the presence of a secretory signal peptide and predicted localization.',
    'We have developed a new predictor, {link}SecreTary{end_link}, for more accurate computational prediction of plant proteins that traffic through the classical secretory pathway. {link}Try SecreTary{end_link},',
    'However, while this is a valuable approach, as with all prediction-based tools, there is a consistent error rate and both false positive and negative predictions should be expected.',
    'One of our major goals is to identify the incorrect predictions and generate a database of computationally and functionally confirmed secreted plant proteins.',
    'We have used both SignalP and our recently developed predictor, {link}SecreTary{end_link}, to screen the predicted proteomes of several plant species to date.',
    'These programs have been greatly refined in recent years and their accuracy has improved with the adoption of machine learning algorithms.',
);

page_sentences_ok(
    '/secretom/detail/proteomics.mas',
    'Tomato has long served as model system for fleshy fruit development, and is an excellent system to study cell wall proteins as it is associated with dramatic changes in wall biology, including enzyme-mediated cell wall polysaccharide degradation, apoplastic sugar metabolism and extracellular defenses against microbial pathogens.',
    'While the genes responsible for all these mutations have been cloned, and important progress has been made in elucidating their respective signaling pathways, numerous aspects remain poorly understood and the degree of regulatory complexity and the multiplicity of underlying molecular mechanisms have far exceeded expectations.',
    'We have been developing methods to obtain sample materials highly enriched in apoplast/cell wall proteins, including vacuum dehydration, centrifugal dehydration and several methods that involve the centrifugal isolation of the cell wall followed by sequential extraction with solutions of increasing ionic strength.',
    'We have been applying several approaches for comparative proteomic analysis, including Difference Gel Electrophoresis (DIGE), isobaric Tag Relative Absolute Protein Quantitation (iTRAQ), exponentially modified protein abundance index (emPAI) and MSE.',
    'We are characterizing the dynamics of host-pathogen secretomes in leaves during infection by the oomycete {species}, during distinct phases of hemibiotrophic infection, using both DIGE and iTRAQ supported with 454-generated transcript profiling.',
    'Additionally we have been profiling "total proteomes"; and screening the resulting protein populations for those known to be localized in the cell wall with a predicted secretory signal peptide, or that are {link}glycosylated{end_link}.',
);

page_sentences_ok(
    '/secretom/detail/secretion_path.mas',
    'Schematic diagram of the plant classical secretory pathway, highlighting protein co-translational translocation from ER-bound ribosomes in the ER lumen and the subsequent major trafficking pathways (N, nucleus; ER, endoplasmic reticulum, Chl, chloroplast; TGN, trans-Golgi network; PVC pre-vacuolar compartment; PM, plasma membrane; CW, cell wall).',
    'Briefly, secreted eukaryotic proteins utilize an N-terminal signal peptide (SP) to direct their co-translation on ER-bound ribosomes into the ER lumen, after which they progress through the endomembrane system and are ultimately exported to the extracellular environment, or cell surface.',
    'Such proteins do not have canonical signal peptides and treatment with chemical inhibitors, such as brefeldin A, which disrupt vesicle trafficking between the ER and Golgi, and does not perturb secretion.',
    'It should be noted that these represent a subset of SP-containing proteins, since others are retained in the ER or Golgi or are redirected to other compartments, such as the vacuole.',
    'The primary route for protein secretion from eukaryotic cells is termed the classical, or endoplasmic reticulum (ER)/Golgi-dependent, secretory pathway.',
    'There is also growing evidence that plant proteins can be secreted to the apoplast via routes that are independent of the ER-Golgi pathway.',
);

done_testing;
