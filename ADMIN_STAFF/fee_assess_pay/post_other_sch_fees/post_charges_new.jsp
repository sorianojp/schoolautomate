
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
  /*this is what we want the div to look like*/
  div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:8;
	top:8;
    /*give it some background and border
    background:#007fb7;*/
	background:#FFCC99;
    border:1px solid #ddd;
  }

body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }
table.thinborder{
	border-top : solid  1px #BB0004;
	border-right : solid 1px #BB0004;
}

TD.thinborder {
    border-left: solid 1px #BB0004;
    border-bottom: solid 1px #BB0004;
} 
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage() {
	if(document.form_.delete_ && document.form_.delete_.checked) {
		if(document.form_.date_posted_fr.length == 0) {
			alert("Please enter date Posted from information");
			document.form_.delete_.checked = false;
			document.form_.date_posted_to.value = '';
			return;
		}
		document.form_.date_posted_to.value = '';
	}
	document.form_.show_list.value = "";
	document.form_.page_action.value = "";	
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.show_list.value = "1";
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
function FeeChanged() {
	var iNoOfUnit = document.form_.no_of_units.value;
	if(iNoOfUnit.length == 0) {
		iNoOfUnit = "1";
		//document.form_.no_of_units.value = "1";
	}
	var iFeeTypeSel = document.form_.fee_type.selectedIndex;
	var strFeeAmt = "";
	eval('strFeeAmt=document.form_.fee_'+iFeeTypeSel+'.value');
	
	document.form_.amt_.value=eval(strFeeAmt);

	//strFeeAmt = eval(strFeeAmt) * eval(iNoOfUnit);
	//document.getElementById('tot_amt').innerHTML = this.formatFloat(strFeeAmt,2,true);
}
function SelALL() {
	var strIsChecked = false;
	if(document.form_.sel_all.checked)
		strIsChecked = true;
	var iMaxDisp = document.form_.max_disp.value;
	if(eval(iMaxDisp) > 500)
		alert("Please be informed, this operation may take few seconds.");
		
	var vObj;
	for(i = 0; i < eval(iMaxDisp); ++i) {
		eval('vObj=document.form_.checkbox_'+i);
		if(!vObj)
			continue;
		if(strIsChecked)
			vObj.checked = true;
		else	
			vObj.checked =false;
	}
}
function DeleteCalled() {
	if(!confirm("Are you sure you want to remove the charged permanently?"))
		return;
		
	document.form_.del_button.disabled=true;
		
	document.form_.show_list.value='1';
	document.form_.page_action.value = '0';
	document.getElementA
	document.form_.submit();
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
}

function HideLayer(strDiv) {
	if(strDiv == '1'){
		document.form_.show_layer.checked = false;
		document.all.processing.style.visibility='hidden';	
	}
	else
		document.all.processing.style.visibility='visible';		
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Post Charges","post_charges_new.jsp");
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
														"Fee Assessment & Payments","Post Charges",request.getRemoteAddr(),
														"post_charges_new.jsp");
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

Vector vStudList  = null;
Vector vRetResult = null;
Vector vSecList   = new Vector(); java.sql.ResultSet rs = null; boolean bolIsSuccess = false;

enrollment.FAFeePost feePost  = new enrollment.FAFeePost();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(feePost.operateOnPostChargeNew(dbOP, request, Integer.parseInt(strTemp)) != null)
		bolIsSuccess = true;
		
	strErrMsg = feePost.getErrMsg();
}

//get the sections available for a subject.
if(WI.fillTextValue("sub_index").length() > 0){
	enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
	vSecList = reportEnrl.getSubSecList(dbOP,request.getParameter("sy_from"),
						request.getParameter("sy_to"),request.getParameter("semester"),
						request.getParameter("sub_index"), null);
}

if(WI.fillTextValue("show_list").length() > 0 && !bolIsSuccess) {
	if(WI.fillTextValue("delete_").length() > 0 && WI.fillTextValue("date_posted_fr").length() == 0)
        strErrMsg = "Please enter Post date (From) Information for delete option.";
	else {
		vStudList = feePost.operateOnPostChargeNew(dbOP, request, 5);
		if(vStudList == null)
			strErrMsg = feePost.getErrMsg();
	}
}




String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
boolean bolIsSWU = strSchCode.startsWith("SWU");

String strSYFrom = null;
String strSYTo   = null;
String strSemester = null;
%>
<form name="form_" action="./post_charges_new.jsp" method="post" onSubmit="SubmitOnceButton(this);">


<%
Vector vCourseInfo = new Vector();
if(WI.fillTextValue("c_index").length() > 0 && strSchCode.startsWith("SWU")){
int iCount = 0;

strTemp = "select course_index, course_code, course_name from course_offered where IS_DEL=0 AND IS_VALID=1  and c_index = "+
	WI.fillTextValue("c_index")+" order by course_code asc";
rs = dbOP.executeQuery(strTemp);

while(rs.next()) {
	vCourseInfo.addElement(rs.getString(1));
	vCourseInfo.addElement(rs.getString(2));
	vCourseInfo.addElement(rs.getString(3));
}
rs.close();	
if(vCourseInfo != null && vCourseInfo.size() > 0){
%>
	<div id="processing" class="processing">
	<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL" bgcolor="#FFCC99">
		  <tr>
			<td valign="top" align="right"><a href="javascript:HideLayer(1)">Close Window</a></td>
		  </tr>
		  <tr>
			  <td valign="top" align="center"><u><b>List of Courses to Exclude</b></u></td>
		  </tr>
		  <tr>
			  <td valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" border="0">						
						<tr>
							<td valign="top">
								<table width="100%" cellpadding="0" cellspacing="0" border="0">
									<%
									for(int i =0; i < vCourseInfo.size(); i += 6){
										strTemp = WI.fillTextValue("_"+iCount);
										if(strTemp.equals((String)vCourseInfo.elementAt(i)))
											strTemp = "checked";
										else
											strTemp = "";
									%>
										<tr>
											<td width="5%"><input type="checkbox" name="_<%=iCount++%>" value="<%=vCourseInfo.elementAt(i)%>" <%=strTemp%>></td>
											<td style="font-size:9px;"><%=vCourseInfo.elementAt(i + 1)%></td>
										</tr>
									<%}%>
								</table>
							</td>
							<td>&nbsp;</td>
							<td valign="top">
								<table width="100%" cellpadding="0" cellspacing="0" border="0">
									<%
									for(int i =3; i < vCourseInfo.size(); i += 6){
										strTemp = WI.fillTextValue("_"+iCount);
										if(strTemp.equals((String)vCourseInfo.elementAt(i)))
											strTemp = "checked";
										else
											strTemp = "";
									%>
										<tr>
											<td width="5%"><input type="checkbox" name="_<%=iCount++%>" value="<%=vCourseInfo.elementAt(i)%>" <%=strTemp%>></td>
											<td style="font-size:9px;"><%=vCourseInfo.elementAt(i + 1)%></td>
										</tr>
									<%}%>
								</table>
							<input type="hidden" name="_count" value="<%=iCount%>">
							</td>
						</tr>					
				</table>
			  </td>
		  </tr>
	</table>
	</div>	
<%}}%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"> <font color="#FFFFFF"><strong>:::: 
          Post Other School Fees Page - Group or Individual Posting::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
      <%if(vCourseInfo != null && vCourseInfo.size() > 0){%><td valign="top" align="right"><input type="checkbox" name="show_layer" onClick="HideLayer(2)">Show Course List</td><%}%>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" width="2%">&nbsp;</td>
      <td width="14%" >School Year</td>
      <td width="34%"> 
<%
strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() ==0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox"
	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
<%
strSYTo = Integer.toString(Integer.parseInt(strSYFrom) + 1);
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strSYTo%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"> 
	  <select name="semester">
<%
strSemester = WI.fillTextValue("semester");
if(strSemester.length() ==0)
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");
if(strSemester.compareTo("0") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";%>
          <option value="0"<%=strErrMsg%>>Summer</option>
<%if(strSemester.compareTo("1") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";%>
          <option value="1"<%=strErrMsg%>>1st Sem</option>
<%if(strSemester.compareTo("2") == 0)
	strErrMsg = " selected";
else	
	strErrMsg = "";%>
          <option value="2"<%=strErrMsg%>>2nd Sem</option>
<%if(strSemester.compareTo("3") == 0)
	strErrMsg = " selected";
else	
	strErrMsg = "";%>
          <option value="3"<%=strErrMsg%>>3rd Sem</option>
        </select></td>
      <td width="50%">
	  	<input name="12345" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.show_list.value='';document.form_.page_action.value = ''" value="Refresh >>">	  </td>
    </tr>
<!--
    <tr bgcolor="#DDDDDD">
      <td height="25">&nbsp;</td>
      <td colspan="3" >Date Posted Range :
        <input name="date_posted_fr" type="text" class="textbox" id="date_attendance" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_posted_fr")%>" size="10" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.date_posted_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> to
        <input name="date_posted_to" type="text" class="textbox" id="date_attendance2" 
	                    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_posted_to")%>" size="10" maxlength="12" readonly>
        <a href="javascript:show_calendar('form_.date_posted_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
		(Note: Displays frequency a student paid this fee for this duration)		</td>
    </tr>
    <tr bgcolor="#DDDDDD">
      <td height="25">&nbsp;</td>
      <td colspan="3" ><input type="checkbox" name="delete_" value="checked" <%=WI.fillTextValue("delete_")%> onClick="ReloadPage();">
      Delete Information for the specific date Posted </td>
    </tr>
-->
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="58%" class="thinborderBOTTOM"><div align="center"><strong>FEE CHARGE(S) DETAILS </strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="18">&nbsp;</td>
      <td width="46%" valign="bottom">Fee type</td>
      <td width="52%" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">
	  <select name="fee_type" onChange="FeeChanged();">
<%
String strHiddenField = "";
int iCount = 0;
double dAmtPerUnit = 0d; int iNoOfUnit = 1;
strTemp = "select OTHSCH_FEE_INDEX,fee_name,amount from FA_OTH_SCH_FEE where is_valid=1 and (year_level=0 or year_level="+
			WI.getStrValue(WI.fillTextValue("year_level"),"0")+") and sy_index=(select sy_index from FA_SCHYR where sy_from="+
			strSYFrom+") and amount > 0.1 order by FEE_NAME asc";
rs = dbOP.executeQuery(strTemp);
strTemp = WI.fillTextValue("fee_type");

while(rs.next()) {
	if(strTemp.length() == 0)
		strTemp = rs.getString(1);
	if(strTemp.equals(rs.getString(1))) {
		strErrMsg = " selected";
		dAmtPerUnit = rs.getDouble(3);
	}
	else	
		strErrMsg = "";
	strHiddenField += "<input type='hidden' name='fee_"+Integer.toString(iCount++)+"' value='"+
						ConversionTable.replaceString(CommonUtil.formatFloat(rs.getDouble(3),true),",","")+"'>";

%>
	<option value="<%=rs.getString(1)%>"<%=strErrMsg%>><%=rs.getString(2)%></option>
<%}rs.close();%>			
      </select></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Unit quantity/usage/requested: 
<%
strTemp = WI.fillTextValue("no_of_units");
if(strTemp.length() == 0) 
	strTemp = "1";
%>
        <input name="no_of_units" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="FeeChanged()"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
      <td ><font color="#0000FF"><strong>Amount payable : 
<%
if(WI.fillTextValue("amt_").length() > 0)
	strErrMsg = WI.fillTextValue("amt_");
else
	strErrMsg = ConversionTable.replaceString(CommonUtil.formatFloat(dAmtPerUnit, true), ",","");
%>
	  <input type="text" name="amt_" value="<%=strErrMsg%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  
<!--
<label id="tot_amt">	  
<%
//iNoOfUnit = Integer.parseInt(strTemp);%>
<%//=CommonUtil.formatFloat(dAmtPerUnit * iNoOfUnit, true)%> </label>
-->
	  </strong></font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Date Posted <font size="1">
<%
strTemp = WI.fillTextValue("date_posted");
if(strTemp.length() ==0)
	strTemp = WI.getTodaysDate(1);
%>
        <input name="date_posted" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_posted');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        </font></td>
      <td >&nbsp;</td>
    </tr>
  </table>
<%=strHiddenField%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="12%" colspan="9"><hr size="1"></td>
    </tr>
  </table>
<!--- Ready now to have filter.. -->
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25">&nbsp;</td>
      <td  colspan="2"><strong><font color="#0000FF"><u>FEE CHARGE TO :</u></font></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Student Status </td>
      <td><select name="stud_stat" style="width:200px;">
        <option value="">No Filter</option>
<%
strTemp = WI.fillTextValue("stud_stat");
if(strTemp.equals("-1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
        <option value="-1"<%=strErrMsg%>>All New(New, Transferee,Cross Enrollee,Second Course) </option>
<%
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
        <option value="0"<%=strErrMsg%>>All OLD(Old, Change Course, Second Course-Old)</option>
<%=dbOP.loadCombo("status_index","status"," from user_status where is_for_student = 1 order by status asc", request.getParameter("stud_stat"), false)%>
      </select></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >College</td>
      <td><select name="c_index" onChange="ReloadPage()" style="width:400px;">
          <option value="">No Filter</option>
          <%=dbOP.loadCombo("c_index","c_name"," from college where is_del = 0 order by c_name asc",
		  		request.getParameter("c_index"), false)%> </select></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Course</td>
      <td>
<%strTemp = WI.fillTextValue("c_index");
if(strTemp.length() > 0) 
	strTemp = " and c_index = "+strTemp;
%>
	  <select name="course_index" onChange="ReloadPage()" style="width:400px;">
          <option value="">No Filter</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+strTemp+" order by course_name asc",
		  		request.getParameter("course_index"), false)%> </select></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Major</td>
      <td><select name="major_index" onChange="ChangeMajor()">
          <option value="">No Filter</option>
<%
strTemp = WI.fillTextValue("course_index");
if(strTemp.length() > 0) {
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
<%}%>
        </select></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Year Level </td>
      <td><select name="year_level"><option value="">No Filter</option>
<%
strTemp = WI.fillTextValue("year_level");
if(strTemp.length() == 0) 
	strTemp = "-1";
int iDefYr = Integer.parseInt(strTemp);
	for(int i = 1; i < 7; ++i) {
		if(iDefYr == i)
			strTemp = " selected";
		else	
			strTemp = "";
		%>
		<option value="<%=i%>"<%=strTemp%> ><%=i%></option>
	<%}%>	  
	  </select>	  </td>
    </tr>
<%if(strSchCode.startsWith("AUF") || strSchCode.startsWith("SWU")){%>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Gender</td>
      <td>
		<select name="gender">
		<option value="">No Filter</option>
		<%
		if(WI.fillTextValue("gender").equals("m"))
			strTemp = " selected";
		else	
			strTemp = "";
		%>
				<option value="m"<%=strTemp%> >Male</option>
		<%
		if(WI.fillTextValue("gender").equals("f"))
			strTemp = " selected";
		else	
			strTemp = "";
		%>
				<option value="f"<%=strTemp%> >Female</option>
		</select>	  	  </td>
    </tr>
<%}%>
    <tr > 
      <td height="25">&nbsp;</td>
      <td colspan="2" >To filter SUBJECT display enter subject code starts with 
        <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="6" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> and click REFRESH
        <input name="123452" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.show_list.value = '';document.form_.page_action.value = ''" value="Refresh >>">        </td>
    </tr>

    <tr > 
      <td height="25">&nbsp;</td>
      <td >Subject</td>
      <td style="color:#0000FF">
<%if(WI.fillTextValue("starts_with").length() ==0) {%>Please enter subject filter to display subject list<%}else{%>
	  <select name="sub_index" onChange="ReloadPage();" style="font-size:11px; width:550px;">
          <option value="">No Filter</option>
<%
strTemp = WI.fillTextValue("starts_with");
if(strTemp.length() > 0)
	strTemp = " from subject where is_del=0 and sub_code like '"+WI.fillTextValue("starts_with")+
				"%' order by sub_code";
else	
	strTemp = " from SUBJECT where IS_DEL=0 order by sub_code";
%>		  
          <%=dbOP.loadCombo("SUB_INDEX","SUB_CODE +' ::: '+sub_name",strTemp,WI.fillTextValue("sub_index") , false)%> 
	    </select>
<%}%>		</td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td >Section </td>
      <td><select name="section">
          <option value="">All Section</option>
          <%
strTemp = WI.fillTextValue("section");
if(vSecList == null)
	vSecList = new Vector();
for(int i=0; i<vSecList.size();i +=2){
	if(strTemp.compareTo((String)vSecList.elementAt(i)) ==0){%>
          <option value="<%=(String)vSecList.elementAt(i)%>" selected><%=(String)vSecList.elementAt(i+1)%></option>
          <%}else{%>
          <option value="<%=(String)vSecList.elementAt(i)%>"><%=(String)vSecList.elementAt(i+1)%></option>
          <%}
}%>
        </select></td>
    </tr>
    <tr > 
      <td width="4%" height="25">&nbsp;</td>
      <td width="11%" >Specific  ID &nbsp; </td>
      <td width="85%"> <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" 
      class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
      onChange = "javascript:HideSaveButton()" onKeyUp="AjaxMapName('1');"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <input name="1234522" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.show_list.value='1';document.form_.page_action.value = ''" value="Show Student list">
	  &nbsp;&nbsp; <input type="checkbox" name="show_not_posted" value="checked" <%=WI.fillTextValue("show_not_posted")%>> 
	  Show only not posted	  </td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td colspan="3"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
  </table>
<%if(vStudList != null && vStudList.size() > 0 ) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong>::: List of Student to Post Charge ::: </strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="6" class="thinborder" style="font-size:10px; font-weight:bold">&nbsp;
	  Total Display : <%=vStudList.size()/6%></td>
    </tr>
    <tr> 
      <td height="25" style="font-size:10px; font-weight:bold" align="center" width="20%" class="thinborder">Student ID</td>
      <td style="font-size:10px; font-weight:bold" align="center" width="40%" class="thinborder">Student Name</td>
      <td style="font-size:10px; font-weight:bold" align="center" width="10%" class="thinborder">Course Code</td>
      <td style="font-size:10px; font-weight:bold" align="center" width="10%" class="thinborder">Year Level</td>
      <td style="font-size:10px; font-weight:bold" align="center" width="10%" class="thinborder">Fee Post  Frequency </td>
      <td style="font-size:10px; font-weight:bold" align="center" width="10%" class="thinborder">Select ALL<br>
        <input type="checkbox" name="sel_all" onClick="SelALL();" value="checked" <%=WI.fillTextValue("sel_all")%>></td>
    </tr>
    <%for(int i = 0; i < vStudList.size(); i += 6){%>
		<tr>
		  <td height="25" class="thinborder">&nbsp;<%=(String)vStudList.elementAt(i + 1)%></td>
		  <td class="thinborder">&nbsp;<%=(String)vStudList.elementAt(i + 2)%></td>
		  <td class="thinborder">&nbsp;<%=(String)vStudList.elementAt(i + 3)%></td>
		  <td class="thinborder" align="center">&nbsp;<%=WI.getStrValue((String)vStudList.elementAt(i + 4), "N/A")%><input type="hidden" name="year_<%=i/6%>" value="<%=WI.getStrValue(vStudList.elementAt(i + 4))%>"></td>
		  <td class="thinborder" align="center">&nbsp;<%=(String)vStudList.elementAt(i + 5)%></td>
		  <td class="thinborder" align="center">&nbsp;<input type="checkbox" name="checkbox_<%=i/6%>" value="<%=vStudList.elementAt(i)%>"></td>
		</tr>
	<%}%>
  </table>
  <input type="hidden" name="max_disp" value="<%=vStudList.size()/6%>">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" align="center">
	  	<%if(WI.fillTextValue("delete_").length() == 0){%>
			<input name="12345222" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.show_list.value='1';document.form_.page_action.value = '1'" value="Post Charges to selected Student">
	  	<%}else{%>
			<input name="del_button" id="del_button" type="button" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="DeleteCalled();" value="Delete Post charges">
		<%}%>
	  </td>
    </tr>
  </table>
  
<%}//if vStudList is not null%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="5" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="print_page">
 <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
 <input type="hidden" name="page_action">
 <input type="hidden" name="show_list">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
