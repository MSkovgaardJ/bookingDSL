/*
 * generated by Xtext 2.24.0
 */
package org.xtext.example.mydsl.validation

import org.eclipse.xtext.validation.Check
import org.xtext.example.mydsl.bookingDSL.Attribute
import org.xtext.example.mydsl.bookingDSL.Booking
import org.xtext.example.mydsl.bookingDSL.BookingDSLPackage
import org.xtext.example.mydsl.bookingDSL.Declaration
import org.xtext.example.mydsl.bookingDSL.System
import java.util.ArrayList
import org.xtext.example.mydsl.bookingDSL.Customer
import java.util.List
import org.xtext.example.mydsl.bookingDSL.Resource
import org.xtext.example.mydsl.bookingDSL.Relation

/** 
 * This class contains custom validation rules. 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class BookingDSLValidator extends AbstractBookingDSLValidator {
	
	@Check 
	def void warnIfNoDisplayName(Declaration declaration) {
		if (declaration instanceof Booking) {
			return;
		}
		var hasName = false
		var members = declaration.getMembers()
		for (var int i = 0; i < members.size(); i++) {
			var member = members.get(i)
			if (member instanceof Attribute) {
				var attriName = ((member as Attribute)).getName()
				if (attriName.equals("name")) {
					hasName = true
				}
			}
		}
		if (!hasName) {
			
			var alreadyExtended = new ArrayList<String>
			
			// Check if a extended superType has a name
			if(declaration instanceof Customer) {
				if(declaration.superType !== null) {
					alreadyExtended.add(Customer.toString())
					if(searchInheritanceForName(declaration, alreadyExtended) == true) {
						return;
					}
				}
			}
			
			if(declaration instanceof Resource) {
				if(declaration.superType !== null) {
					alreadyExtended.add(Resource.toString())
					if(searchInheritanceForName(declaration, alreadyExtended) == true) {
						return;
					}
				}
			}
			
			
			// Return warning that there are no name attribute
			warning("This declaration has no name attribute", BookingDSLPackage.eINSTANCE.baseDeclaration_Name)
			return;
		}
	}
	
	def dispatch boolean searchInheritanceForName(Customer declaration, List<String> alreadyExtended) {
		if(declaration.superType !== null) {
			if(declaration.superType.members.filter(Attribute).filter[e | e.name.equals("name")].length > 0) {
				return true
			}
			
			if(alreadyExtended.filter[e | e.equals(declaration.superType.toString())].length > 0) {
				return false;
			} else {
				alreadyExtended.add(declaration.superType.toString())
				return searchInheritanceForName(declaration.superType, alreadyExtended)
			}
		}
		return false;
	}
	
	def dispatch boolean searchInheritanceForName(Resource declaration, List<String> alreadyExtended) {
		if(declaration.superType !== null) {
			if(declaration.superType.members.filter(Attribute).filter[e | e.name.equals("name")].length > 0) {
				return true
			}
			
			
			if(alreadyExtended.filter[e | e.equals(declaration.superType.toString())].length > 0) {
				return false;
			} else {
				alreadyExtended.add(declaration.superType.toString())
				return searchInheritanceForName(declaration.superType, alreadyExtended)
			}
		}
		return false;
	}
	
	@Check 
	def void errorIfSystemNameIsLowerCase(System sys) {
		if (Character::isLowerCase(sys.getName().charAt(0))) {
			error("System name start with an uppercase letter", BookingDSLPackage::eINSTANCE.system_Name)
		}
	}
	
	@Check 
	def void errorIfAttrubuteIsUpperCase(Attribute attribute) {
		if (Character::isUpperCase(attribute.getName().charAt(0))) {
			error("attribute name must start with a lowercase letter", BookingDSLPackage.eINSTANCE.baseDeclaration_Name)
		}
	}
	
	@Check
	def void errorIfCustomerNameIsLowercase(Customer customer) 
	{
		if (Character::isLowerCase(customer.getName().charAt(0)))
		{
			error("Customer name cannot start with a lowercase letter", BookingDSLPackage.eINSTANCE.baseDeclaration_Name)
		}
	}

	@Check 
	def void errorIfDisplayNameIsNotString(Attribute attri) {
		var attriName = attri.getName()
		if (attriName.equals(("name"))) {
			var attriType = attri.getType().getLiteral()
			if (!attriType.equals("string")) {
				error("Attribute of type name can only be of type string",
					BookingDSLPackage::eINSTANCE.getAttribute_Name())
				return;
			}
		}
	}


	
	@Check 
	def void errorIfHasMultipleAttributesWithSameNames(Declaration declaration) {
		var members = declaration.getMembers();
		var checkedMembers = new ArrayList<String>();
		for (var int i = 0; i < members.size(); i++) {
			var member = members.get(i)
			if (member instanceof Attribute) {
				var attriName = member.getName();
				if (!checkedMembers.isNullOrEmpty() && checkedMembers.contains(attriName)) {
					error("Cannot have multiple attributes with the same name: " + attriName.toString(), BookingDSLPackage::eINSTANCE.getBaseDeclaration_Name())
				}
				checkedMembers.add(attriName);
				
			}
		}
	}
	
	@Check 
	def void errorIfHasSameAttrubuteAsInherited(Declaration declaration) {
		var attributessChecked = new ArrayList<String>();

		if(declaration instanceof Customer) {
			if(declaration.superType !== null) {
				errorIfHasInheritedAttributeDeclaired(declaration.superType, attributessChecked)
			}
		}
		
		if(declaration instanceof Resource) {
			if(declaration.superType !== null) {
				errorIfHasInheritedAttributeDeclaired(declaration.superType, attributessChecked)
			}
		}
	}
	
	def dispatch errorIfHasInheritedAttributeDeclaired(Customer cus, ArrayList<String> attributesChecked) {
		var inheritedMembers = cus.superType.members.filter(Attribute);
		for (var int i = 0; i<inheritedMembers.size(); i++){
			var inherAttributeName = inheritedMembers.get(i).getName();
			var members = cus.members.filter(Attribute);
			for (var int j = 0; i<members.size(); j++){
				if(members.get(j).getName().toString() == inherAttributeName.toString() && members.get(j).getName().toString() !== 'name'){
					error("Attribute is inherited", BookingDSLPackage.eINSTANCE.baseDeclaration_Name)
					return null;
				}
			}
			
			
		}
	}
	
	def dispatch errorIfHasInheritedAttributeDeclaired(Resource res, ArrayList<String> attributesChecked) {
		var inheritedMembers = res.superType.members.filter(Attribute);
		for (var int i = 0; i<inheritedMembers.size(); i++){
			var inherAttributeName = inheritedMembers.get(i).getName();
			var members = res.members.filter(Attribute);
			for (var int j = 0; i<members.size(); j++){
				if(members.get(j).getName().toString() == inherAttributeName.toString() && members.get(j).getName().toString() !=='name'){
					error("Attribute is inherited", BookingDSLPackage.eINSTANCE.baseDeclaration_Name)
					return null;
				}
			}
			
		}
	}
	
	@Check
	def void errorIfCycInheritance(Declaration dec) {
		
		var alreadyExtended = new ArrayList<String>

		if(dec instanceof Customer) {
			alreadyExtended.add(Customer.toString())
			if(dec.superType !== null) {
				errorIfCycInheritance(dec.superType, alreadyExtended)
			}
		}
		
		if(dec instanceof Resource) {
			alreadyExtended.add(Resource.toString())
			if(dec.superType !== null) {
				errorIfCycInheritance(dec.superType, alreadyExtended)
			}
		}
	}
	
	def dispatch errorIfCycInheritance(Customer dec, ArrayList<String> alreadyExtended) {
			if(alreadyExtended.filter[e | e.equals(dec.superType.toString())].length > 0) {
				error("Cyclic dependency detected", BookingDSLPackage.eINSTANCE.baseDeclaration_Name)
				return null;
			} else {
				alreadyExtended.add(dec.superType.toString())
				errorIfCycInheritance(dec.superType, alreadyExtended)
			}

		return null;
	}
	
	def dispatch errorIfCycInheritance(Resource dec, ArrayList<String> alreadyExtended) {
			if(alreadyExtended.filter[e | e.equals(dec.superType.toString())].length > 0) {
				error("Cyclic dependency detected", BookingDSLPackage.eINSTANCE.baseDeclaration_Name)
				return null;
			} else {
				alreadyExtended.add(dec.superType.toString())
				errorIfCycInheritance(dec.superType, alreadyExtended)
			}
		return null;
	}
}
