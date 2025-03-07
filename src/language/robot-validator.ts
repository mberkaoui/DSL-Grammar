import type { ValidationAcceptor, ValidationChecks } from 'langium';
import type { RobotAstType, Expression,Fonction, DeclarationVar, AffectVar, AppelFct, BoucleWHILE, InstructionIF, BoucleFOR, Block, Programme } from './generated/ast.js';
import type { RobotServices } from './robot-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: RobotServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = new RobotValidator();
    const checks: ValidationChecks<RobotAstType> = {
        Fonction: validator.checkFunctionNameStartsWithCapital,
        DeclarationVar: validator.checkVariableDeclaration,
        AffectVar: validator.checkVariableAssignment,
        AppelFct: validator.checkFunctionCallExistsAndParametersMatch,
        BoucleWHILE: validator.checkWhileLoop,
        InstructionIF: validator.checkIfStatement,
        BoucleFOR: validator.checkForLoop,
        Block: validator.checkDuplicateVariableDeclarations,
        Programme: validator.checkDuplicateFunctionNames
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class RobotValidator {

    // Vérifie que le nom de la fonction commence par une majuscule
    checkFunctionNameStartsWithCapital(fonction: Fonction, accept: ValidationAcceptor): void {
      if (fonction.nom) {
          const firstChar = fonction.nom.substring(0, 1);
          if (firstChar.toLowerCase() !== firstChar) {
              accept('warning', 'Function name should start with a lowercase letter.', { node: fonction, property: 'nom' });
          }
      }
  }

    // Vérifie que le nom de la variable commence par une lettre ou un underscore
    checkVariableDeclaration(declaration: DeclarationVar, accept: ValidationAcceptor): void {
        if (declaration.nom && !/^[a-zA-Z_]/.test(declaration.nom)) {
            accept('error', 'Variable name should start with a letter or underscore.', { node: declaration, property: 'nom' });
        }
    }

    // Vérifie que le nom de la variable dans une affectation commence par une lettre ou un underscore
    checkVariableAssignment(affectation: AffectVar, accept: ValidationAcceptor): void {
        if (affectation.nom && !/^[a-zA-Z_]/.test(affectation.nom)) {
            accept('error', 'Variable name should start with a letter or underscore.', { node: affectation, property: 'nom' });
        }
    }

    checkFunctionCallExistsAndParametersMatch(appel: AppelFct, accept: ValidationAcceptor): void {
      // Récupérer le programme pour accéder à la liste des fonctions
      const programme = this.getProgramme(appel);
      if (!programme || !programme.fonction) {
          return;
      }

      // Trouver la fonction correspondante
      const fonctionAppelee = programme.fonction.find(f => f.nom === appel.nom);
      if (!fonctionAppelee) {
          accept('error', `Function '${appel.nom}' does not exist.`, { node: appel, property: 'nom' });
          return;
      }

      // Vérifier le nombre de paramètres
      const nbParametresAttendus = fonctionAppelee.parametre.length;
      const nbArgumentsFournis = appel.argument?.length || 0;

      if (nbArgumentsFournis !== nbParametresAttendus) {
          accept('error', `Function '${appel.nom}' expects ${nbParametresAttendus} arguments, but ${nbArgumentsFournis} were provided.`, { node: appel, property: 'argument' });
          return;
      }

      // Vérifier les types des arguments
      for (let i = 0; i < nbArgumentsFournis; i++) {
          const argument = appel.argument![i];
          const parametre = fonctionAppelee.parametre[i];
          const typeArgument = this.getTypeOfExpression(argument);
          const typeParametre = parametre.type;

          if (typeArgument && typeParametre && typeArgument !== typeParametre) {
              accept('error', `Type mismatch for argument ${i + 1} in function '${appel.nom}': expected '${typeParametre}', but got '${typeArgument}'.`, { node: argument, property: 'value' });
          }
      }
  }

  // Méthode utilitaire pour récupérer le type d'une expression
  private getTypeOfExpression(expression: Expression): string | undefined {
      if (expression.$type === 'CstNumber') {
          return 'number';
      } else if (expression.$type === 'CstBool') {
          return 'Boolean';
      } else if (expression.$type === 'Const' && typeof expression.$type === 'string') {
          return 'String';
      } else if (expression.$type === 'Variable') {
          // Si c'est une variable, vous devez récupérer son type déclaré
          // Cela nécessite une gestion supplémentaire (voir explication ci-dessous)
          return undefined;
      }
      // Ajouter d'autres cas selon vos besoins
      return undefined;
  }

  // Méthode utilitaire pour récupérer le programme
  private getProgramme(node: any): Programme | undefined {
      while (node && node.$type !== 'Programme') {
          node = node.$container;
      }
      return node as Programme | undefined;
  }

    // Vérifie que la condition de la boucle WHILE est valide
    checkWhileLoop(boucle: BoucleWHILE, accept: ValidationAcceptor): void {
        if (boucle.condition && !boucle.condition) {
            accept('error', 'While loop condition should be a valid expression.', { node: boucle, property: 'condition' });
        }
    }

    // Vérifie que la condition de l'instruction IF est valide
    checkIfStatement(instruction: InstructionIF, accept: ValidationAcceptor): void {
        if (instruction.condition && !instruction.condition) {
            accept('error', 'If statement condition should be a valid expression.', { node: instruction, property: 'condition' });
        }
    }

    // Vérifie que la boucle FOR a un compteur valide et une incrémentation valide
    checkForLoop(boucle: BoucleFOR, accept: ValidationAcceptor): void {
        if (boucle.compteur && !boucle.compteur.nom) {
            accept('error', 'For loop counter should have a valid name.', { node: boucle, property: 'compteur' });
        }
        if (boucle.incrementation && !boucle.incrementation) {
            accept('error', 'For loop incrementation should be a valid expression.', { node: boucle, property: 'incrementation' });
        }
    }

    checkDuplicateVariableDeclarations(block: Block, accept: ValidationAcceptor): void {
      console.log('Checking duplicate variable declarations in block:', block);
      const declaredVariables = new Set<string>();
  
      for (const statement of block.statement) {
          if (statement.$type === 'DeclarationVar') {
              const declaration = statement as DeclarationVar;
              if (declaredVariables.has(declaration.nom)) {
                  accept('error', `Variable '${declaration.nom}' is already declared in this scope.`, { node: declaration, property: 'nom' });
              } else {
                  declaredVariables.add(declaration.nom);
              }
          }
      }
  }

  checkDuplicateFunctionNames(programme: Programme, accept: ValidationAcceptor): void {
    const functionNames = new Set<string>();

    if (programme.fonction) {
        for (const fonction of programme.fonction) {
            if (fonction.nom) {
                if (functionNames.has(fonction.nom)) {
                    accept('error', `Function '${fonction.nom}' is already exist.`, { node: fonction, property: 'nom' });
                } else {
                    functionNames.add(fonction.nom);
                }
            }
        }
    }
}
}