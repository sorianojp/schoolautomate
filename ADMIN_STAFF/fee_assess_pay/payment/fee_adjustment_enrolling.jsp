<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.FAPayment,enrollment.FAFeeOperation,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	String[] astrConvertSem= {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Fee adjustments","fee_adjustment_enrolling.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"fee_adjustment_enrolling.jsp");
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","PAYMENT-FEE ADJUSTMENT",request.getRemoteAddr(),
														"fee_adjustment_enrolling.jsp");
}
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vStudInfo = new Vector();

//float fTotalAdjustment = 0f;

String strFAFAIndex = null;
String[] astrCovnertDiscUnit={"Peso","%","unit"};
String[] astrConvertDisOn = {"Tuition Fee", "Misc Fee", "Free all", "Other Tuition Fee", "TUITION + MISC FEE","MISC FEE + OTH CHARGES",
								"OTH CHARGES","Tuition+Misc+Oth"};
String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr","8th Yr"};
String[] astrConvertProper  = {""," (Preparatory)"," (Proper)"};
FAPmtMaintenance pmtMaintenance = new FAPmtMaintenance();
EnrlAddDropSubject enrlAddDropSub = new EnrlAddDropSubject();
FAPayment faPayment = new FAPayment();

boolean bolIsBasic = false;

int iEnrolledStat = -1;//0 = not enrolled, 1 = enrolled.
boolean bolIsTempStud = false;

if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("stud_id").length() > 0) {
	vStudInfo = enrlAddDropSub.getEnrolledStudInfo(dbOP, (String)request.getSession(false).getAttribute("userId"),
												request.getParameter("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),
												WI.fillTextValue("semester"));
	if(vStudInfo != null) {
		strErrMsg = "<a href='./fee_adjustment.jsp'>Click here to go to Apply Discount for Enrolled student.</a>";
		vStudInfo = null;
		iEnrolledStat = 1;
	}
	else {
		enrollment.Advising advising = new enrollment.Advising();
		vStudInfo = advising.getStudInfo(dbOP,WI.fillTextValue("stud_id"));
		if(vStudInfo == null)
			strErrMsg = "Enrolling Information not found. Please student's Registration.";
		else {
			//check if enrolling for same sy-term. 
			if(!WI.fillTextValue("sy_from").equals(vStudInfo.elementAt(16)) || !WI.fillTextValue("sy_to").equals(vStudInfo.elementAt(17)) || !WI.fillTextValue("semester").equals(vStudInfo.elementAt(18)) ){
				strErrMsg = "Student enrolling information not found.";
				iEnrolledStat = -1;
			}
			else {
				iEnrolledStat = 0;
				if(((String)vStudInfo.elementAt(10)).equals("1"))
					bolIsTempStud = true;
			}
		}	
	}
}

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{
	if(!faPayment.operateOnAdjustmentEnrolling(dbOP,request, Integer.parseInt(strTemp)))
		strErrMsg = faPayment.getErrMsg();
	else {
		if(strTemp.equals("0"))
			strErrMsg = "Adjustment removed successfully.";
		else	
			strErrMsg = "Adjustment added successfully.";
	}
}


//get the list of discounts.. this is to remove discount if wrongly applied.. 
Vector vDiscountApplied = new Vector();
String strSQLQuery      = null;
java.sql.ResultSet rs   = null;
Vector vDiscountDtls    = new Vector();
int iIndexOf            = 0;

if(vStudInfo != null && vStudInfo.size() > 0) {	//check if already having discount.
	strSQLQuery = "select fa_fa_index, adj_index from FA_STUD_PMT_ADJUSTMENT where user_index = "+(String)vStudInfo.elementAt(0)+" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+
				WI.fillTextValue("semester");
	if(bolIsTempStud)
		strSQLQuery += " and is_valid = 0 and is_del = 0";
	else
		strSQLQuery +=" and is_valid = 1";
		
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vDiscountApplied.addElement(rs.getString(1));
		vDiscountApplied.addElement(new Integer(rs.getInt(2)));
	}
	rs.close();
}

String strIsValid = "1";
if(bolIsBasic)
	strIsValid = "2";

//get all discounts. 
if(WI.fillTextValue("sy_from").length() > 0) {
	strSQLQuery = "select fa_fa_index,main_type_name, sub_type_name1, sub_type_name2, sub_type_name3, sub_type_name4, sub_type_name5, "+
					"discount_unit, discount_on, discount from FA_FEE_ADJUSTMENT where is_valid = "+strIsValid+" and sy_from = "+WI.fillTextValue("sy_from")+
					" and (semester is null or semester = "+WI.fillTextValue("semester")+") and discount is not null "+
					"order by main_type_name, sub_type_name1, sub_type_name2, sub_type_name3, sub_type_name4, sub_type_name5";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vDiscountDtls.addElement(rs.getString(1));
		strTemp = rs.getString(2);
		if(rs.getString(3) != null)
			strTemp += "-"+rs.getString(3);
		if(rs.getString(4) != null)
			strTemp += "-"+rs.getString(4);
		if(rs.getString(5) != null)
			strTemp += "-"+rs.getString(5);
		if(rs.getString(6) != null)
			strTemp += "-"+rs.getString(6);
		if(rs.getString(7) != null)
			strTemp += "-"+rs.getString(7);
		if(rs.getInt(10) == 2)
			strTemp += " (Free All)";
		else
			strTemp = strTemp + " ("+CommonUtil.formatFloat(rs.getDouble(10), false)+astrCovnertDiscUnit[rs.getInt(8)]+" on "+astrConvertDisOn[rs.getInt(9)]+")";
		vDiscountDtls.addElement(strTemp);
	}
	rs.close();
}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function FocusID() {
	document.form_.stud_id.focus();
}
function PageAction(strAction, strInfoIndex)
{
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this entry.'))
			return;
	}
	
	document.form_.page_action.value =strAction;
	document.form_.info_index.value =strInfoIndex;
	document.form_.submit();
}
function ReloadPage()
{
	this.SubmitOnce("form_");
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<form name="form_" action="fee_adjustment_enrolling.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="24" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          FEE ADJUSTMENTS PAGE <%if(bolIsBasic){%> - FOR BASIC <%}%> - FOR ENROLLING STUDENT::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="57%"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
      <td width="41%" align="right" style="font-weight:bold; font-size:18px;"><%if(iEnrolledStat > -1) {%>STUDENT <%if(iEnrolledStat == 0){%>NOT<%}%> ENROLLED<%}%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td height="25">Enter Student ID</td>
      <td width="11%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
      <td width="7%" height="25"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="61%">
	  <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
	  
	  <%if(vDiscountApplied.size() > 0) {%>
		  <div align="right" style="font-size:18px; font-weight:bold; color:#FF0000">
				Student is already having discount. 		  </div>
	      <%}%>	  </td>
    </tr>
    
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="19%" height="25">School Year/Sem</td>
      <td height="25" colspan="3">
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        -
        <select name="semester">
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> </td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="6"><hr size="1"></td>
    </tr>
    <tr>
      <td  width="2%" height="20">&nbsp;</td>
      <td width="43%">Student name :<strong> <%=(String)vStudInfo.elementAt(1)%>
  	  <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
	  <input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(6)%>">

	  </strong></td>
      <td  colspan="4">Course / Major:<strong> 
	  <%if(bolIsBasic){%>
	  	<%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudInfo.elementAt(6)), false)%>
	  <%}else{%>
	  	<%=(String)vStudInfo.elementAt(22)%>/ <%=WI.getStrValue(vStudInfo.elementAt(23))%>
	  <%}%>
	  </strong></td>
    </tr>
<%if(!bolIsBasic){%>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Year :<strong><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(6),"0"))]%></strong>
      </td>
      <td  colspan="4">&nbsp;</td>
    </tr>
<%}%>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr>
      <td width="2" colspan="2"><hr size="1"></td>
    </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Educational Assistance</td>
      <td><strong>
        <select name="assistance0" style="width:400px;">
		<option value="">Select</option>
		<%
		strTemp = WI.fillTextValue("assistance0");
		for(int i = 0; i < vDiscountDtls.size(); i += 2) {
			if(strTemp.equals(vDiscountDtls.elementAt(i)))
				strErrMsg = " selected";
			else	
				strErrMsg = "";
		%>
			<option value="<%=vDiscountDtls.elementAt(i)%>" <%=strErrMsg%>><%=vDiscountDtls.elementAt(i + 1)%></option>
		<%}%>
        </select>
        </strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="48%">
	  	<table width="100%" cellpadding="0" cellspacing="0">
			<tr>
			  <td height="25">
				Date Approved: <font size="1">
				<input name="date_of_payment" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_of_payment")%>" class="textbox"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_of_payment');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
				</font>      </td>
		    </tr>
			<tr>
			  <td height="25">
				Approval No. :&nbsp;&nbsp;
				<input name="approval_number" type="text" size="16" value="<%=WI.fillTextValue("approval_number")%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">        </td>
		    </tr>
			<tr>
			  <td height="25">
			  Note: <br>
			  <textarea name="adjustment_note" class="textbox" rows="3" cols="50"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("adjustment_note")%></textarea>	  </td>
		    </tr>
		</table>	  </td>
      <td width="2%">&nbsp;</td>
      <td width="48%" valign="top">
	  <%if(vDiscountApplied.size()> 0) {%>
	  	<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
	  		<tr>
				<td align="center" bgcolor="#cccccc" style="font-weight:bold; font-size:11px;" class="thinborder" colspan="2">List of Discount Already Applied</td>
			</tr>
			<%for(int i =0; i <  vDiscountApplied.size(); i += 2) {
				iIndexOf = vDiscountDtls.indexOf(vDiscountApplied.elementAt(i));
				if(iIndexOf == -1)
					strTemp = "Description not found.";
				else	
					strTemp = (String)vDiscountDtls.elementAt(iIndexOf + 1);
				%>
				<tr>
					<td class="thinborder" width="85%"><%=strTemp%></td>
					<td class="thinborder"><a href="javascript:PageAction('0','<%=vDiscountApplied.elementAt(i + 1)%>');"><img src="../../../images/delete.gif" border="0"></a></td>
				</tr>
			<%}%>
		</table>	  
	  <%}%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 <%if(iAccessLevel > 1){%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%" height="25">&nbsp;</td>
      <td width="80%" height="25">
	  <a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
        <font size="1">click to save entries</font>
	  </td>
    </tr>
<%}//if iAccessLevel > 1%>
  </table>
<%}%>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="stud_id_old" value="<%=WI.fillTextValue("stud_id")%>">

<%if(bolIsTempStud){%>
	<input type="hidden" name="is_temp_stud" value="1">
<%}else{%>
	<input type="hidden" name="is_temp_stud" value="0">
<%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
