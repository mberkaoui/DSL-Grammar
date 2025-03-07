import 'XMLType-types'

type Type = Type_Void | Type_Number | Type_Boolean | Type_String | Type_Length;
type Type_Void = 'void';
type Type_Number = 'number';
type Type_Boolean = 'Boolean';
type Type_String = 'String';
type Type_Length = 'Length';

type Unite = Unite_cm | Unite_mm;
type Unite_cm = 'cm';
type Unite_mm = 'mm';

type Bool = Bool_False | Bool_True;
type Bool_False = 'False';
type Bool_True = 'True';

type Direction = Direction_DROITE | Direction_GAUCHE | Direction_AVANT | Direction_ARRIERE;
type Direction_DROITE = 'RIGHT';
type Direction_GAUCHE = 'LEFT';
type Direction_AVANT = 'FORWARD';
type Direction_ARRIERE = 'BACKWARD';


type OperateurType = OperateurComparaison_SUP | OperateurComparaison_INF | OperateurComparaison_EG  | OperateurArith_PLUS | OperateurArith_MOINS | OperateurArith_DIV | OperateurArith_MULT | OperateurBoolean_OR | OperateurBoolean_AND | OperateurBoolean_NOT;
type OperateurComparaison_SUP = '>';
type OperateurComparaison_INF = '<';
type OperateurComparaison_EG = '==';
type OperateurArith_PLUS = '+';
type OperateurArith_MOINS = '-';
type OperateurArith_DIV = '/';
type OperateurArith_MULT = '*';
type OperateurBoolean_OR = '|';
type OperateurBoolean_AND = '&';
type OperateurBoolean_NOT = '!';

/////////////////////////////////////////////////:
interface Programme {
    fonction?: Fonction[];
}

interface Fonction {
	nom?: String0;
	parametre: Parametre[];
	returnsType?: Type;
	block: Block;
}

interface Parametre{
    nom:String0
    ^type?: Type
}

interface Statement {
	next?: Statement;
}

interface Expression {}


interface DeclarationVar extends Statement {
	nom: String0;
	type: Type;
	valeur?: Expression;
}

interface Variable extends Expression {
    nom: string;
}

interface AppelFct extends Expression, Statement {
	nom: String0;
	argument?: Expression[];
	//fonction: @Fonction;
}

interface AffectVar extends Statement {
	nom: string;
    valeur: Expression;
}

interface Mouvement extends Statement {
	direction: Direction;
	valeur: Expression;
}

interface Operateur extends Expression {
	left: Expression;
	right: Expression;
	operateur: OperateurType;
}

interface CstBool extends Const {
    valeur : Bool
}
interface Const extends Expression {}

interface CstNumber extends Const {
    valeur: int
}

interface Longueur extends Const {
    valeur:Expression;
    unite: Unite;
}

interface Rotation extends Statement {
	angle: Expression;
}

interface Vitesse extends Statement {
	valeur: CstNumber;
	unite: Unite;
}

//interface Affectation extends Statement {
	//valeur: Expression;
	//declarationvar?: @DeclarationVar;
    //variable?: Variable;
//}

interface Capteur extends Statement {}

interface Time extends Capteur {}

interface BoucleWHILE extends StructureDeControle {}

interface StructureDeControle extends Statement {
    condition:Expression
	block: Block;
}

interface Block {
	statement: Statement[];
}

interface InstructionIF extends StructureDeControle {
	blockELSE?: Block;
}

interface BoucleFOR extends StructureDeControle {
	compteur: DeclarationVar;
	incrementation: Expression;
	blockELSE?: Block;
}
