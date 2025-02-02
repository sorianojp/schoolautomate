<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.form_.print_pg.value='1'
	document.form_.submit();
}
function ConfirmAssignment() {
	if(document.form_.assign_count.selectedIndex == 0) {
		alert("Please select number of records to assign");
		return;
	}
	document.form_.print_pg.value = '';
	document.form_.page_action.value = '1';
	document.form_.submit();
}
function RemoveAssignment() {
	if(!confirm('Are you sure you want to remove remove assignment.'))
		return;
	
	document.form_.print_pg.value = '';
	document.form_.page_action.value = '0';
	document.form_.submit();
}
function SelectALL() {
	var bolIsChecked = document.form_.sel_all.checked;
	var iMaxCount = document.form_.max_added.value;
	var obj;
	for(i = 0; i <= iMaxCount; ++i) {
		eval('obj=document.form_.pmid_'+i);
		if(!obj)
			continue;
		obj.checked = bolIsChecked;
	}
}
</script>
<body bgcolor="#FFFFFF">
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}
	
	if(iAccessLevel == -1) {//for fatal error.
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main_files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	///if print is called, forward here. 
	if(WI.fillTextValue("print_pg").length() > 0) {%>
		<jsp:forward page="./auf_posted_to_ledger_print3.jsp" />
	<%return;}

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","auf_posted_to_ledger_print2.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
	Vector vAssigned = new Vector();
	Vector vNotAssigned = new Vector();
	
	String strAuthID = (String)request.getSession(false).getAttribute("userIndex");

String strSQLQuery = null;
String strExtraCon = "";


///add or delete here 
strTemp = WI.fillTextValue("page_action");
if(strTemp.equals("1")) {
	///i have to assign now. 
	int iAssignCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("assign_count"), "0"));
	strSQLQuery = null;
	for(int i = 1; i <= iAssignCount; ++i) {
		strTemp = WI.fillTextValue("pmi_"+i);
		if(strTemp.length() == 0) 
			continue;
		
		if(strSQLQuery == null)
			strSQLQuery = strTemp;
		else	
			strSQLQuery += ","+strTemp;
	}
	if(strSQLQuery == null) 
		strErrMsg = "Please select number of records to be assigned.";
	else {
		strSQLQuery = "update fa_stud_payment set auf_ledg_printed_manual = "+strAuthID+", auf_ledg_printed_manual_date='"+WI.getTodaysDate()+
						"' where auf_ledg_printed_manual is null and payment_index in ("+strSQLQuery+")";
		iAssignCount = dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
		if(iAssignCount == 0) {
			strErrMsg = "Failed to update records. Please check record and assign again.";
		}
		else	
			strErrMsg = "Total Record Updated: "+iAssignCount;
	}
}
else if(strTemp.equals("0")) {
	///i have to assign now. 
	int iAssignCount = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_added"), "0"));
	strSQLQuery = null;
	for(int i = 1; i <= iAssignCount; ++i) {
		strTemp = WI.fillTextValue("pmid_"+i);
		if(strTemp.length() == 0) 
			continue;
		
		if(strSQLQuery == null)
			strSQLQuery = strTemp;
		else	
			strSQLQuery += ","+strTemp;
	}
	if(strSQLQuery == null) 
		strErrMsg = "Please select number of records to be removed.";
	else {
		strSQLQuery = "update fa_stud_payment set auf_ledg_printed_manual = null, auf_ledg_printed_manual_date=null where payment_index in ("+
						strSQLQuery+")";
		iAssignCount = dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
		if(iAssignCount == 0) {
			strErrMsg = "Failed to update records. Please check record and remove again.";
		}
		else	
			strErrMsg = "Total Record Removed: "+iAssignCount;
	}
}

if(WI.fillTextValue("date_fr").length() > 0) {
	if(WI.fillTextValue("date_to").length() > 0)
		strExtraCon = " and date_paid between '"+ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_fr"), false)+"' and '"+
						ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_to"), false)+"' ";
	else
		strExtraCon = " and date_paid = '"+ConversionTable.convertTOSQLDateFormat(WI.fillTextValue("date_fr"), false)+"' ";
	
	//get all assigned to this user.. 
	strSQLQuery = "select date_paid, fa_stud_payment.created_by,createdBy.id_number, or_number, amount,payment_index, null from fa_stud_payment "+
					//"postedBy.id_number, auf_ledg_printed_manual_date from fa_stud_payment "+
					" join user_table as createdBy on (createdBy.user_index = fa_stud_payment.created_by) "+
					//" join user_table as postedBy on (postedBy.user_index = auf_ledg_printed_manual) "+
					" where fa_stud_payment.or_number is not null and fa_stud_payment.is_valid = 1 and "+
					"fa_stud_payment.amount > 0 "+strExtraCon+" and auf_ledg_printed_manual = "+strAuthID+" order by createdBy.id_number, date_paid, or_number";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vAssigned.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(1)));//[0] date_paid
		vAssigned.addElement(new Integer(rs.getInt(2)));//[1] created_by
		vAssigned.addElement(rs.getString(3));//[2] createdBy.id_number
		vAssigned.addElement(rs.getString(4));//[3] or_number
		vAssigned.addElement(CommonUtil.formatFloat(rs.getDouble(5), true));//[4] amount
		vAssigned.addElement(rs.getString(6));//[5] id_number of whoever is going to post manually
		vAssigned.addElement(null);
		//vAssigned.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(7)));//[6] auf_ledg_printed_date
	}					
	rs.close();	
					
	
	strSQLQuery = "select date_paid, fa_stud_payment.created_by,createdBy.id_number, or_number, amount,payment_index, null from fa_stud_payment "+
					" join user_table as createdBy on (createdBy.user_index = fa_stud_payment.created_by) "+
					" where fa_stud_payment.or_number is not null and fa_stud_payment.is_valid = 1 and "+
					"fa_stud_payment.amount > 0 "+strExtraCon+//add condition auf_ledg_printed_by is null :: meaning not printed by teller.. 
					" and auf_ledg_printed_by is null and auf_ledg_printed_manual is null order by createdBy.id_number, date_paid, or_number";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vNotAssigned.addElement(ConversionTable.convertMMDDYYYY(rs.getDate(1)));//[0] date_paid
		vNotAssigned.addElement(new Integer(rs.getInt(2)));//[1] created_by
		vNotAssigned.addElement(rs.getString(3));//[2] createdBy.id_number
		vNotAssigned.addElement(rs.getString(4));//[3] or_number
		vNotAssigned.addElement(CommonUtil.formatFloat(rs.getDouble(5), true));//[4] amount
		vNotAssigned.addElement(rs.getString(6));//[5] payment_index
		vNotAssigned.addElement(null);//[6] 
	}					
	rs.close();	
}




%>

<form name="form_" method="post" action="./auf_posted_to_ledger_print2.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          POSTED TO LEDGER ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td style="font-weight:bold; font-size:16px;"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" height="25">Collection Date</td>
      <td width="83%" height="25" colspan="3"><font size="1">
<%
strTemp = WI.fillTextValue("date_fr");
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
        to
        <%
strTemp = WI.fillTextValue("date_to");
%>
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
        (for one day, leave to field empty.)
        </font>
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="image" src="../../../../images/form_proceed.gif" onClick="document.form_.page_action.value='';document.form_.print_pg.value=''">		</td>
    </tr>
  </table>

<!------------------- display report here ------------------------->
<%
int iCount = 0;
if(vNotAssigned != null && vNotAssigned.size() > 0) {%>
	<div style="height: 250px; width:auto; overflow: auto; border: inset black 1px;">
	  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#CCFFFF">
		<tr style="font-weight:bold">
		  <td align="center" height="22" class="thinborderBOTTOM" valign="bottom"> --- List of Payments not Assigned for Manual Posting --- </td>
	    </tr>
		<tr style="font-weight:bold; color:#0000FF">
		  <td>
		  Total Not Assigned: <%=vNotAssigned.size()/7%>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  Total Assigned: <%=vAssigned.size()/7%>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  Assign to self (from 1 to): <select name="assign_count">
		  <option value=""></option>
		  <%
		  int iDefVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("assign_count"), "0"));
		  for(int i = 1; i <= vNotAssigned.size()/7; ++i) {
		  	if(iDefVal == i)
				strTemp = "selected";
			else	
				strTemp = "";
			%>
			<option value="<%=i%>" <%=strTemp%>><%=i%></option>
		  	<%}%>
			</select>
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  <input type="button" name="12" value=" Confirm Assignment >>> " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="ConfirmAssignment();">

		  
		  </td>
	    </tr>
	  </table>
	  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#CCFFFF">
		<tr style="font-weight:bold">
		  <td width="4%" class="thinborderTOPBOTTOM">SL # </td>
		  <td width="24%" height="22" class="thinborderTOPBOTTOM">OR Date</td>
		  <td width="24%" class="thinborderTOPBOTTOM">Cashier #</td>
		  <td width="24%" class="thinborderTOPBOTTOM">OR Number </td>
		  <td width="24%" class="thinborderTOPBOTTOM" align="right">Amount</td>
	    </tr>
		<%for(int i = 0; i < vNotAssigned.size(); i += 7) {%> 
			<tr>
			  <td height="18" style="font-size:9px;"><%=++iCount%></td>
			  <td style="font-size:9px;"><%=vNotAssigned.elementAt(i)%></td>
			  <td style="font-size:9px;"><%=vNotAssigned.elementAt(i + 2)%></td>
			  <td style="font-size:9px;"><%=vNotAssigned.elementAt(i + 3)%></td>
			  <td align="right" style="font-size:9px;"><%=vNotAssigned.elementAt(i + 4)%></td>
			</tr>
			<input type="hidden" name="pmi_<%=iCount%>" value="<%=vNotAssigned.elementAt(i + 5)%>">
		<%}%>
      </table>
	</div>
<%
}//end of main loop .. if vRetResult != null%>

<%
iCount = 0;
if(vAssigned != null && vAssigned.size() > 0) {%>
<table bgcolor="#FFFFFF" width="100%" cellpadding="0" cellspacing="0">
	<tr><td>&nbsp;</td></tr>
	<tr><td align="right">
	<a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>
	  <font size="1">click to print already assigned </font>
	 </td></tr>
</table>
	<div style="height: 250px; width:auto; overflow: auto; border: inset black 1px;">
	  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
		<tr style="font-weight:bold">
		  <td align="center" height="22" class="thinborderNONE" valign="bottom"> --- List of Payments Already Assigned for Manual Posting --- </td>
	    </tr>
	  </table>
	  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
		<tr style="font-weight:bold">
		  <td width="5%" class="thinborderTOPBOTTOM">SL # </td>
		  <td width="20%" height="22" class="thinborderTOPBOTTOM">OR Date</td>
		  <td width="20%" class="thinborderTOPBOTTOM">Cashier #</td>
		  <td width="20%" class="thinborderTOPBOTTOM">OR Number </td>
		  <td width="20%" class="thinborderTOPBOTTOM" align="right">Amount</td>
	      <td width="15%" class="thinborderTOPBOTTOM" align="center">Select All: 
		    <input type="checkbox" name="sel_all" onClick="SelectALL();">
		  </td>
		</tr>
		<%for(int i = 0; i < vAssigned.size(); i += 7) {%> 
			<tr>
			  <td height="18" style="font-size:9px;"><%=++iCount%></td>
			  <td style="font-size:9px;"><%=vAssigned.elementAt(i)%></td>
			  <td style="font-size:9px;"><%=vAssigned.elementAt(i + 2)%></td>
			  <td style="font-size:9px;"><%=vAssigned.elementAt(i + 3)%></td>
			  <td align="right" style="font-size:9px;"><%=vAssigned.elementAt(i + 4)%></td>
			  <td align="center" style="font-size:9px;"><input type="checkbox" name="pmid_<%=iCount%>" value="<%=vAssigned.elementAt(i + 5)%>"></td>
			</tr>
		<%}%>
      </table>
	  <input type="hidden" name="max_added" value="<%=iCount%>">
	</div>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#CCCCCC">
		<tr style="font-size:10px;">
		  <td align="center" height="22" class="thinborderNONE" valign="bottom"> 
		  <input type="button" name="12" value=" Remove Assignment >>> " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="RemoveAssignment();">
		  Delete selected Records (Remove from assignment) </td>
	    </tr>
	</table>

<%
}//end of main loop .. if vRetResult != null%>

<input type="hidden" name="page_action">
<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
