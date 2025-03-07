grammar Robot
import 'Terminals'
import 'robotML_Model-types'
import 'XMLType-types'

entry Programme returns Programme:
    (fonction+=Fonction ( fonction+=Fonction)*)?
;

Statement returns Statement:
    Mouvement | 
    Rotation | 
    DeclarationVar |
    AffectVar | 
    AppelFct | 
    BoucleWHILE | 
    BoucleFOR | 
    InstructionIF |
    Vitesse
;

Expression returns Expression:
    "(" Expression1 ")" | Expression1
;

Expression1 returns Expression:
    AppelFct | Operateur | CstBool | CstNumber | STRING | Longueur | Variable 
;

ExpressionPrim returns Expression:
     "(" ExpressionPrim1 ")" | ExpressionPrim1
;

ExpressionPrim1 returns Expression:
    AppelFct | CstBool | CstNumber | STRING | Longueur | Variable
;

LongueurExpression returns Expression:
    CstNumber | Variable | AppelFct
;

Fonction returns Fonction:
    'let' returnsType=Type nom=ID
        '('
        (parametre+=Parametre (',' parametre+=Parametre)*)? ')'
        block=Block  
;

Parametre returns Parametre:
nom=ID ':' ^type=Type
;

Type returns Type:
    Type_Void | Type_Number | Type_Boolean | Type_String | Type_Length
;
Type_Void returns Type_Void: 'void' ;
Type_Number returns Type_Number: 'number' ;
Type_Boolean returns Type_Boolean: 'Boolean' ;
Type_String returns Type_String: 'String' ;
Type_Length returns Type_Length: 'Length' ;


DeclarationVar returns DeclarationVar:
    'var' type=Type nom=ID ('=' valeur=Expression)?
;

AffectVar returns AffectVar:
    (nom=ID)? '=' valeur=Expression
;
Variable returns Variable:
    nom=ID
;

CstBool returns CstBool:
    valeur= Bool_False | Bool_True
;
Bool_False returns Bool_False: 'False' ;
Bool_True returns Bool_True: 'True' ;

CstNumber returns CstNumber:
    valeur=INT
;

Unite returns Unite:
    Unite_mm | Unite_cm
;
Unite_mm returns Unite_mm : 'mm' ;
Unite_cm returns Unite_cm : 'cm' ;

AppelFct returns AppelFct:
    nom=ID '('
        (argument+=Expression (',' argument+=Expression)*)?
    ')'
;

Operateur returns Operateur:
    left=ExpressionPrim operateur=OperateurType right=Expression
;

Longueur returns Longueur:
    (valeur=LongueurExpression 'in' unite=Unite) |
    (valeur=LongueurExpression unite=Unite)
;

Rotation returns Rotation:
    'Clock' angle=Expression   
;

Vitesse returns Vitesse:
    'setSpeed' '(' (valeur=CstNumber 'in' unite=Unite) ')'
;

Block returns Block:
    '{' 
        (statement+=Statement ( statement+=Statement)*)?
    '}'
;
Mouvement returns Mouvement:
    direction=Direction valeur=Expression
;

BoucleWHILE returns BoucleWHILE:
    'loop' '('condition=Expression')'
    block=Block
;

InstructionIF returns InstructionIF:
    'if' '(' 
        condition=Expression ')'
        block=Block
        ('else' blockELSE=Block)?
;
BoucleFOR returns BoucleFOR:
    'for' '('
    compteur=DeclarationVar
    incrementation=Expression
    condition=Expression ')'
    block=Block
    
;

OperateurType returns OperateurType:
    OperateurComparaison_SUP | 
    OperateurComparaison_INF |
    OperateurComparaison_EG |
    OperateurArith_PLUS |
    OperateurArith_MOINS |
    OperateurArith_DIV |
    OperateurArith_MULT |
    OperateurBoolean_OR |
    OperateurBoolean_AND |
    OperateurBoolean_NOT
;
OperateurComparaison_SUP returns  OperateurComparaison_SUP: '>';
OperateurComparaison_INF returns OperateurComparaison_INF : '<';
OperateurComparaison_EG returns  OperateurComparaison_EG: '==';
OperateurArith_PLUS returns OperateurArith_PLUS : '+';
OperateurArith_MOINS returns OperateurArith_MOINS : '-';
OperateurArith_DIV returns OperateurArith_DIV : '/';
OperateurArith_MULT returns OperateurArith_MULT  : '*';
OperateurBoolean_OR returns OperateurBoolean_OR  : '|';
OperateurBoolean_AND returns OperateurBoolean_AND : '&';
OperateurBoolean_NOT returns  OperateurBoolean_NOT: '!';

Direction returns Direction:
 'FORWARD' | 'BACKWARD' | 'LEFT' | 'RIGHT'
;
