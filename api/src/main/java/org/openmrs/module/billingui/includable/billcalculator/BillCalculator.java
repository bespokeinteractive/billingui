/**
 *  Copyright 2009 Society for Health Information Systems Programmes, India (HISP India)
 *
 *  This file is part of Billing module.
 *
 *  Billing module is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  Billing module is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Billing module.  If not, see <http://www.gnu.org/licenses/>.
 *
 **/

package org.openmrs.module.billingui.includable.billcalculator;

import java.math.BigDecimal;
import java.util.Map;


public interface BillCalculator {

	/**
	 * Return the rate to calculate for a particular bill item
	 * @param parameters TODO
	 * @return
	 */
	public BigDecimal getRate(Map<String, Object> parameters);

	/**
	 * Determine whether a bill should be free or not
	 * @param parameters TODO
	 * @return
	 */
	public boolean isFreeBill(Map<String, Object> parameters);
}
