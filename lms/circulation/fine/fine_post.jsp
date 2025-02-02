<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script src="../../../jscript/common.js"></script>
<script src="../../../jscript/date-picker.js"></script>
<script language="javascript">
function SavePayment(iIndex) {
	document.form_.page_action.value = "1";
	document.form_.index_.value = iIndex;
}
function ReloadPage(pgSubmit) {
	document.form_.fine_code.value = document.form_.fine_type[document.form_.fine_type.selectedIndex].text;
	document.form_.page_action.value = "";
	if(pgSubmit == 1) {
		//alert("double submit");
		document.form_.submit();
	}
}
function UpdateBalance() {
	var iFineAmt   = document.form_.fine_amt.value;
	var iAmtPaid   = document.form_.amt_paid.value;
	var iAmtWaived = document.form_.amt_waived.value;
	if(iFineAmt.length ==0)
		iFineAmt = 0;
	if(iAmtPaid.length ==0)
		iAmtPaid = 0;
	if(iAmtWaived.length ==0)
		iAmtWaived = 0;
	var iAmtBalance = eval(iFineAmt) - eval(iAmtPaid) - eval(iAmtWaived);
	if(eval(iAmtBalance) < 0) {
		alert("Balance can't be -ve");
		return;
	}
	iAmtBalance = iAmtBalance * 100;
	iAmtBalance = Math.round(iAmtBalance);
	iAmtBalance = iAmtBalance/100;
	document.getElementById("balance").innerHTML = eval(iAmtBalance);
	
}
function CloseWnd() {
	window.opener.document.form_.submit();
	self.close();
}
</script>
<%@ page language="java" import="utility.*,lms.LmsUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null; String strTemp = null;
	String strUserIndex  = WI.fillTextValue("user_i");

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Circulation-Patrons Fine".toUpperCase()),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Circulation".toUpperCase()),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
//end of authenticaion code.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Circulation-FineMgmt","fine_main_page.jsp");
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

boolean bolFineTypeDamaged  = false;
boolean bolFineTypeOD       = false;
boolean bolFineTypeSelected = false;

boolean bolReadyToFine      = true;

boolean bolFinePosted       = false;


if(WI.fillTextValue("fine_type").length() > 0) {
	bolFineTypeSelected = true;
	strTemp = WI.fillTextValue("fine_code");
	if(strTemp.equals("Damaged") || strTemp.equals("Lost"))
		bolFineTypeDamaged = true;
	else if(strTemp.equals("Over Due"))
		bolFineTypeOD = true;
}
else {
	bolReadyToFine = false;
}

lms.FineManagement fineMgmt = new lms.FineManagement();
if(WI.fillTextValue("page_action").length() > 0) {
	if(fineMgmt.postFine(dbOP, WI.fillTextValue("user_i"), request)) {
		strErrMsg = "Fine posted successfully. <a href='javascript:CloseWnd();'>Click here to close this window.</a>";
		bolFinePosted = true;
	}
	else	
		strErrMsg = fineMgmt.getErrMsg();
}
if(bolFinePosted) {
	bolFineTypeSelected = false;
}
	
	String[] astrTime     = {"8","9","10","11","12","13","14","15","16","17","18","19","20","21"};
	String[] astrTimeDisp = {"8AM","9AM","10AM","11AM","12PM","1PM","2PM","3PM","4PM","5PM","6PM","7PM","8PM","9PM"};
%>
<body bgcolor="#D0E19D">
<form action="./fine_post.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#77A251"><div align="center"><font color="#FFFFFF" ><strong>::::
        FINE MANAGEMENT == POST FINE  ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
</table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td colspan="4"><font size="1">Patron Name (ID) : 
		<b>
<%
java.sql.ResultSet rs = dbOP.executeQuery("select fname,mname,lname,id_number from user_table where "+
						"user_index="+strUserIndex);
rs.next();
%><%=WI.formatName(rs.getString(1),rs.getString(2),rs.getString(3),4) + " ("+rs.getString(4)+")"%>
<%rs.close();%>		
		</b>
		</font></td>
      </tr>
<%if(strErrMsg != null){%>
      <tr>
        <td colspan="4"><font size="3" color="#FF0000"><b><%=strErrMsg%></b></font></td>
      </tr>
<%}%>
      <tr>
        <td height="10" colspan="4"><hr size="1"></td>
      </tr>
	  <tr>
        <td width="22%" height="25" class="thinborderNONE">Fine Type</td>
        <td width="38%"><select name="fine_type" onChange="ReloadPage(1);">
          <option value="">Select Fine Type</option>
          <%=dbOP.loadCombo("fine_type_index","DESCRIPTION as fcode",
	" from LMS_FINE_TYPE where fine_code <> 'R' order by fine_type_index", WI.fillTextValue("fine_type"), false)%>
        </select></td>
        <td width="20%">&nbsp;</td>
        <td width="20%">&nbsp;</td>
	  </tr>
<%if(bolFineTypeSelected){///show only if fine type is selected.%>	  
	  <tr>
	    <td height="25" colspan="2" valign="top">
<%
///show only if over due or damaged book type is selected.
if(bolFineTypeDamaged || bolFineTypeOD){
String strBookTitle   = null;
String strAccessionNo = null;
if(WI.fillTextValue("accession_no").length() > 0) {
	rs = dbOP.executeQuery("select accession_no, book_title from lms_lc_main where accession_no = '"+
		WI.fillTextValue("accession_no")+"' or barcode_no='"+WI.fillTextValue("accession_no")+
		"' and is_valid = 1");
	if(rs.next()) {
		strAccessionNo = rs.getString(1);
		strBookTitle   = rs.getString(2);
	}
	rs.close();
}
if(strAccessionNo == null)
	bolReadyToFine = false;
 %>
   		<table width="100%" border="0" cellpadding="0" cellspacing="0">
				  <tr>
					<td width="37%" height="25" class="thinborderNONE">Accession #/ Barcode</td>
					<td width="63%"><input type="text" name="accession_no" value="<%=WI.fillTextValue("accession_no")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" size="20" maxlength="32">&nbsp;&nbsp;
				    <input type="submit" name="Proceed" value="List Book >>" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="ReloadPage(0);"></td>
				  </tr>
				  <tr>
					<td height="25" class="thinborderNONE">Accession # </td>
					<td class="thinborderNONE"><%=WI.getStrValue(strAccessionNo,"&nbsp;")%></td>
				  </tr>
				  <tr>
					<td height="25" class="thinborderNONE">Book Title</td>
					<td class="thinborderNONE"><%=WI.getStrValue(strBookTitle,"&nbsp;")%></td>
				  </tr>
			<%if(bolFineTypeOD && false){%>
				  <tr>
					<td height="25" class="thinborderNONE">Due Date &amp; Time </td>
					<td>
						<input name="due_date" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=WI.fillTextValue("due_date")%>">
						<a href="javascript:show_calendar('form_.due_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></font>
						<select name="due_time" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
						<option value="">N/A</option>
						<%
						strTemp = WI.fillTextValue("due_time");
						for(int p =0; p < astrTime.length; ++p){
							if(strTemp.compareTo(astrTime[p]) == 0){%>
								<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
							<%}else{%>
								<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
							<%}//end of else.
						}//end of for%>
						</select>					
					</td>
				  </tr>
				  <tr>
					<td height="25" class="thinborderNONE">Return Date &amp; Time </td>
					<td>
						<input name="ret_date" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
					  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=WI.fillTextValue("ret_date")%>">
						<a href="javascript:show_calendar('form_.ret_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></font>
						<select name="ret_time" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
						<option value="">N/A</option>
						<%
						strTemp = WI.fillTextValue("ret_time");
						for(int p =0; p < astrTime.length; ++p){
							if(strTemp.compareTo(astrTime[p]) == 0){%>
								<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
							<%}else{%>
								<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
							<%}//end of else.
						}//end of for%>
						</select>					
					</td>
				  </tr>
			<%}//if(bolFineTypeOD)%>
			</table>		
<%}//only if if(bolFineTypeDamaged || bolFineTypeOD){%>		</td>
	    <td colspan="2" valign="top">
    		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			</table>
<%if(bolReadyToFine){//if not yet ready to fine%>
		    <table width="100%" border="0" cellpadding="0" cellspacing="0">
              <tr>
                <td width="6%" height="25">&nbsp;</td>
                <td width="30%" class="thinborderNONE">Fine Amount </td>
                <td width="64%" class="thinborderNONE"><span class="thinborder">
                  <input type="text" class="textbox" style="font-size:11px;" 
	  		value="<%=WI.fillTextValue("fine_amt")%>" size="8" name="fine_amt" 
			onKeyUp="AllowOnlyFloat('form_','fine_amt');UpdateBalance();"
			onBlur="AllowOnlyFloat('form_','fine_amt');">
                </span></td>
              </tr>
              <tr>
                <td height="25">&nbsp;</td>
                <td class="thinborderNONE">Amount Paid </td>
                <td><span class="thinborder">
                  <input type="text" class="textbox" style="font-size:11px;" 
	  		value="<%=WI.fillTextValue("amt_paid")%>" size="8" name="amt_paid" onKeyUp="UpdateBalance();">
                </span></td>
              </tr>
              <tr>
                <td height="25">&nbsp;</td>
                <td class="thinborderNONE">Waived</td>
                <td><span class="thinborder">
                  <input type="text" class="textbox" style="font-size:11px;" 
	  		value="<%=WI.fillTextValue("amt_waived")%>" size="8" name="amt_waived" onKeyUp="UpdateBalance();">
                </span></td>
              </tr>
              <%//if(bolFineTypeOD){%>
              <tr>
                <td height="25">&nbsp;</td>
                <td class="thinborderNONE">Balance</td>
                <td><label id="balance" style="color:#FF0000; font-weight:bold"></label></td>
              </tr>
<script language="javascript">
	this.UpdateBalance();
</script>
             <tr>
                <td height="25">&nbsp;</td>
                <td colspan="2" align="center"><input type="submit" value="Post Fine" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="ReloadPage(0);document.form_.page_action.value=1">
                <font size="1">&nbsp;&nbsp;&nbsp;Click to post fine</font></td>
              </tr>
            </table>
<%}//if bolReadyToFine)%>
			</td>
      </tr>
	  <tr>
	    <td width="22%" height="25">&nbsp;</td>
	    <td width="38%">&nbsp;</td>
	    <td width="20%">&nbsp;</td>
	    <td width="20%">&nbsp;</td>
      </tr>
<%}//bolFineTypeSelected%>
    </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td height="25">&nbsp;</td>
    <td width="49%" valign="middle">&nbsp;</td>
    <td width="50%" valign="middle">&nbsp;</td>
  </tr>
  <tr bgcolor="#77A251"> 
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="user_i" value="<%=WI.fillTextValue("user_i")%>"><!-- to save index -->
<input type="hidden" name="fine_code">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>