<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex)
{
	document.form_.page_action.value = strAction;
	if(strAction == '1')
		document.form_.sub_i.value = strInfoIndex;
	else
		document.form_.info_index.value = strInfoIndex;
		
	this.SubmitOnce("form_");
}

function checkAll() {
	var maxDisp = document.form_.max_disp.value;
	//unselect if it is unchecked.
	if(!document.form_.selAll.checked) {
		for(var i =0; i< maxDisp; ++i)
			eval('document.form_.fee_'+i+'.checked=false');
	}
	else {
		for(var i =0; i< maxDisp; ++i)
			eval('document.form_.fee_'+i+'.checked=true');
	}
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function FocusID() {
	document.form_.stud_id.focus();
}


/*** this ajax is called for required downpayment update **/
function ajaxUpdateReqDP() {
	//if there is no change, just return here..
	if(document.form_.reqd_dp_old.value == document.form_.reqd_dp_per_stud.value)
		return;
	
	var strReqDP = document.form_.reqd_dp_per_stud.value;
	if(strReqDP == '')  {
		alert("Please enter an amount. 0 amount is a valid entry as well.");
		return;
	}
	var strParam = "stud_ref="+document.form_.stud_index.value+"&sy_from="+document.form_.sy_from.value+
					"&semester="+document.form_.semester.value+"&is_tempstud="+document.form_.is_tempstud.value+
					"&req_dp="+strReqDP;
	var objCOAInput = document.getElementById("coa_info");
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=114&"+strParam;
	this.processRequest(strURL);
}

function AjaxMapName() {
	var strSearchCon = "&search_temp=2";

		var strCompleteName = "";
		if(document.form_.stud_id)
			strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 3)
			return;
		
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2"+strSearchCon+"&name_format=5&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
		//document.getElementById("coa_info").innerHTML=this.strPrevEntry+this.bolReturnStrEmpty
}
function UpdateID(strID, strUserIndex) {
	//do nothing.
	document.form_.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.FAFeeOptional,enrollment.CourseRequirement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Adivising-Optional Fee","assessment_fee_exclude_persub.jsp");
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
														"Enrollment","Advising & Scheduling",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) 
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","ASSESSMENT",request.getRemoteAddr(),
														null);
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
boolean bolIsTempStud  = false;
Vector vCRStudInfo     = null;
Vector vSubEnrolled = null;
Vector vExcludeList    = null;

CourseRequirement cRequirement = new CourseRequirement();
FAFeeOptional faOptional       = new FAFeeOptional();
boolean bolIsBasic 			   = false;

String strStudIndex = null;

if(WI.fillTextValue("stud_id").length() > 0 && WI.fillTextValue("sy_from").length() > 0) {
	vCRStudInfo = cRequirement.getStudInfo(dbOP, request.getParameter("stud_id"),WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"),WI.fillTextValue("semester") );
	if(vCRStudInfo != null) {
		if(((String)vCRStudInfo.elementAt(10)).compareTo("1") == 0)
			bolIsTempStud = true;
		strStudIndex = (String)vCRStudInfo.elementAt(0);
		if(vCRStudInfo.elementAt(2).equals("0"))
			bolIsBasic = true;
	}
	else
		strErrMsg = cRequirement.getErrMsg();
}


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0 && strStudIndex != null) {
	if(faOptional.operateOnExcludeFeePerSubject(dbOP, request, Integer.parseInt(strTemp), strStudIndex, (String)vCRStudInfo.elementAt(10)) == null) 
		strErrMsg = faOptional.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}	
if(strStudIndex != null) {
	vSubEnrolled = faOptional.operateOnExcludeFeePerSubject(dbOP, request, 3, strStudIndex, (String)vCRStudInfo.elementAt(10));//System.out.println(faOptional.getErrMsg());
	vExcludeList = faOptional.operateOnExcludeFeePerSubject(dbOP, request, 4, strStudIndex, (String)vCRStudInfo.elementAt(10));System.out.println(faOptional.getErrMsg());
}




String[] astrConvertToSem          = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
String[] astrConvertToYr           = {"N/A","1ST YR","2ND YR","3RD YR","4TH YR","5TH YR","6TH YR","7TH YR","","","","","","","",""};
String[] astrConvertMiscOthCharge  = {"Misc", "OC"};


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<form name="form_" action="./assessment_fee_exclude_persub.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: Exclude Subject in Other Charge Computation ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
</table>
   
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="9%">Student ID</td>
      <td width="32%"><input type="text" name="stud_id" size="20" maxlength="32" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" <%=strTemp%> onKeyUp="AjaxMapName();"></td>
      <td width="57%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td colspan="2"><label id="coa_info" style="position:relative"></label></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>SY-Term</td>
      <td>
<%
strTemp = request.getParameter("sy_from");
if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"  
	  onKeyUP="AllowOnlyInteger('form_','sy_from');DisplaySYTo('form_','sy_from','sy_to')">
        to 
<%
strTemp = request.getParameter("sy_to");
if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
<%
	strTemp = request.getParameter("semester");
	if(strTemp == null) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	
%>
        <select name="semester">
<%
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
      <td><input name="image" type="image" src="../../../images/form_proceed.gif" onClick="document.form_.page_action.value = '';"></td>
    </tr>
    <tr> 
      <td height="19" colspan="4"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>
<%
if(strStudIndex != null) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%">Student Name</td>
      <td width="33%"><strong><%=(String)vCRStudInfo.elementAt(1)%></strong></td>
      <td width="47%">ENROLLING STATUS : <font color="#9900FF"><strong> 
        <%
	  if( ((String)vCRStudInfo.elementAt(9)).compareTo("0") ==0){%>
        ENROLLING 
        <%}else{%>
        ENROLLED 
        <%}%>
        </strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course/Major(cy)</td>
      <td colspan="2"><strong>
	  <%if(bolIsBasic){%>
	 	<%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vCRStudInfo.elementAt(6)), false)%>
	  <%}else{%>
		  <%=(String)vCRStudInfo.elementAt(7)%> <%=WI.getStrValue((String)vCRStudInfo.elementAt(8),"/","","")%>
      <%}%>
	  (<%=(String)vCRStudInfo.elementAt(4)%> to <%=(String)vCRStudInfo.elementAt(5)%> )</strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>YEAR LEVEL</td>
      <td><strong><%=astrConvertToYr[Integer.parseInt(WI.getStrValue(vCRStudInfo.elementAt(6),"0"))]%></strong></td>
      <td>Status: <strong><%=(String)vCRStudInfo.elementAt(11)%></strong></td>
    </tr>
<%if(strSchCode.startsWith("UC")) {%>
    
<%}%>
<!--
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Foreign Student</td>
      <td colspan="2"><font color="#9900FF"><strong> 
        <%
	  if( ((String)vCRStudInfo.elementAt(16)).compareTo("1") ==0){%>
        YES 
        <%}else{%>
        NO 
        <%}%>
        </strong></font></td>
    </tr>
-->	
    <tr> 
      <td height="19" colspan="4"><hr size="1" color="#0000FF"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td align="right" valign="top"> <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td height="25" colspan="3" bgcolor="#97ABC1" class="thinborderALL"><div align="center"><strong>::: List of Subject Enrolled :::</strong></div></td>
          </tr>
          <tr> 
            <td height="25" bgcolor="#FFFFDF" class="thinborderBOTTOMLEFT" align="center"><!--Select <input type="checkbox" name="selAll" onClick="checkAll();" checked>-->&nbsp;</td>
            <td bgcolor="#FFFFDF" class="thinborderBOTTOMLEFT" align="center">Sub Code  </td>
            <td bgcolor="#FFFFDF" class="thinborderBOTTOMLEFT" align="center">Sub Name </td>
          </tr>
          <%
		int j = 0;
		if(vSubEnrolled != null && vSubEnrolled.size() > 0) {//scroll down... to get else.
			for(int i = 0; i < vSubEnrolled.size(); i +=3,++j){%>
          <tr> 
            <td width="14%" height="25" class="thinborderBOTTOMLEFT" align="center"> <a href="javascript:PageAction('1', '<%=(String)vSubEnrolled.elementAt(i)%>');">Exclude</a>			</td>
            <td width="27%" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vSubEnrolled.elementAt(i + 1)%></td>
            <td width="59%" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vSubEnrolled.elementAt(i + 2)%></td>
          </tr>
          <%}//end of for loop.%>
          <tr> 
            <td height="25" colspan="3" class="thinborderBOTTOMLEFTRIGHT">&nbsp; </td>
          </tr>
          <%}else{%>
          <tr> 
            <td height="25" colspan="3" class="thinborderBOTTOMLEFTRIGHT">&nbsp; Subject Enrolled List not found. </td>
          </tr>
          <%}%>
          <input type="hidden" name="max_disp" value="<%=j%>">
        </table></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td align="right" valign="top"> 
		<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td height="25" colspan="3" bgcolor="#3366FF" class="thinborderALL"><div align="center"><font color="#FFFFFF"><strong>::: List of Subject excluded in Other Charge Computation ::: </strong></font></div></td>
          </tr>
          <tr> 
            <td height="25" bgcolor="#FFFFDF" class="thinborderBOTTOMLEFT"><div align="center">SUB CODE </div></td>
            <td bgcolor="#FFFFDF" class="thinborderBOTTOMLEFT"><div align="center">SUB NAME </div></td>
            <td bgcolor="#FFFFDF" class="thinborderBOTTOMLEFTRIGHT"><div align="center">REMOVE</div></td>
          </tr>
          <%
		if(vExcludeList != null && vExcludeList.size() > 0) //scroll down... to get else.
			for(int i = 0; i < vExcludeList.size(); i +=3){%>
          <tr> 
            <td width="31%" height="25" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vExcludeList.elementAt(i + 1)%></td>
            <td width="49%" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vExcludeList.elementAt(i + 2)%></td>
            <td width="20%" class="thinborderBOTTOMLEFTRIGHT"><a href="javascript:PageAction(0,'<%=(String)vExcludeList.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a></td>
          </tr>
          <%}//end of for loop.%>
        </table>  	  </td>	
    </tr>
  </table>
  <%}//show only if vCRStudInfo is not null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<%if(strStudIndex !=null) {%>
	<input type="hidden" name="course_index" value="<%=vCRStudInfo.elementAt(2)%>">
	<input type="hidden" name="major_index" value="<%=WI.getStrValue(vCRStudInfo.elementAt(3))%>">
	<input type="hidden" name="year_level" value="<%=WI.getStrValue(vCRStudInfo.elementAt(6))%>">
	<input type="hidden" name="stud_index" value="<%=strStudIndex%>">
	<input type="hidden" name="is_tempstud" value="<%=(String)vCRStudInfo.elementAt(10)%>">
<%}%>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="sub_i">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
