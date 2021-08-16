/*
 * generated by Xtext 2.24.0
 */
package org.xtext.example.mydsl.tests

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import static org.junit.Assert.assertTrue
import org.xtext.example.mydsl.bookingDSL.System
import com.google.inject.Inject
import org.xtext.example.mydsl.bookingDSL.BookingDSLPackage
import org.eclipse.xtext.testing.XtextRunner
import org.junit.runner.RunWith
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.xtext.example.mydsl.validation.BookingDSLValidator

@ExtendWith(InjectionExtension)
@RunWith(XtextRunner)
@InjectWith(BookingDSLInjectorProvider)
class BookingDSLValidationTest {
	@Inject extension ParseHelper<System> parseHelper
	@Inject extension ValidationTestHelper
	
	@Test
	def void T00_systemName()
	{
		val result = parseHelper.parse('''
		system hhh {
			customer cus1 {
				name:string
				}
		}
		''')
		Assertions.assertNotNull(result.name);
	}
	
	
	@Test
	def void testForUppercaseSystemName(){
		val testCase01 = parseHelper.parse('''
			system hotel {
				customer Guest {
					name:string
					age: int
				}
			}
			''')
			val errors = testCase01.eResource.errors;
			testCase01.assertError(BookingDSLPackage::eINSTANCE.system, null, "System name start with an uppercase letter");
	}
	
	 @Test
	 def void testForUpperCaseNameOnCustomer() {
	 	parseHelper.parse(systemWithLowercaseCustomerName).assertError(BookingDSLPackage::eINSTANCE.customer,null, 'Customer name cannot start with a lowercase letter');
	 }
	
	@Test
	def void testForCicrularInheritance() {
		parseHelper.parse(systemWithCircularInheritance).assertError(BookingDSLPackage::eINSTANCE.system,null, 'Cyclic dependency detected');
	}
	@Test
	def void test101(){
		val testCase2 = parseHelper.parse('''
		system Resturant{
			booking tableBooking{
				name:string
				amount: int
				}
				customer Guest{
					name: string
					arrival: int
					}
		}''');
		testCase2.assertNoErrors();
		
	}
	
	def String getSystemWithLowercaseCustomerName() {
		'''
		system Hotel {
			customer guest {
				name: string
				}
		}
		'''
	}
	
	def String getSystemWithCircularInheritance() {
		'''
		system Resturant {
			customer Guest {
				name: string
				age: int
				points: int
				}
			customer MiddelClass extends HighClass{
				name: string
				
				}
			customer HighClass extends MiddelClass {
				name: string
				}
			booking TableBooking {
				amount: int
				from: int
				to: int
				constraint (from < to)
				name: string
				}
		}
		'''
	}
}

 