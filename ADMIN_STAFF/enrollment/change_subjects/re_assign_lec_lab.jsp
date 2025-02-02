<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function FocusID() {
	document.form_.stud_id.focus();
}
function saveChanges() {
	document.form_.saveChanges.value = "1";
	document.form_.submit();
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
}
</script>
<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,enrollment.EnrlAddDropSubject,enrollment.Advising,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String strStudID = WI.fillTextValue("stud_id");
	int iMaxDisplayed = 0;
	boolean bolFatalErr = false;

	int j=0; //this is the max display variable.
	String[] astrSchYrInfo = {WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester")};
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

	String strDegreeType = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-CHANGE OF SUBJECTS","re_assign_lec_lab.jsp");
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
														"Enrollment","CHANGE OF SUBJECTS",request.getRemoteAddr(),
														"re_assign_lec_lab.jsp");
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

//I have to give an option to set do not check conflict incase user is super user.
boolean bolIsSuperUser = comUtil.IsSuperUser(dbOP,(String)request.getSession(false).getAttribute("userId"));
//end of authenticaion code.

String strMaxAllowedLoad = "0"; // this is the first field of the vAdvisingList
String strOverLoadDetail = null;//Overload detail if there is any.

Vector vEnrolledList = new Vector();
Vector vStudInfo = new Vector();
Vector vAdviseList = new Vector();

Advising advising = new Advising();
EnrlAddDropSubject enrlAddDropSub = new EnrlAddDropSubject();

if(!bolFatalErr && strStudID.length() > 0)
{
	vStudInfo = enrlAddDropSub.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),strStudID,
                                    astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
	if(vStudInfo == null)
	{
		bolFatalErr = true;
		strErrMsg = enrlAddDropSub.getErrMsg();
	}
	else {
		if(dbOP.strBarcodeID != null)
			strStudID = dbOP.strBarcodeID;
	}
	if(!bolFatalErr)
	{
		Vector vMaxLoadDetail = advising.getMaxAllowedUnit(dbOP,strStudID,(String)vStudInfo.elementAt(5),(String)vStudInfo.elementAt(6),
			astrSchYrInfo[0],astrSchYrInfo[1],(String)vStudInfo.elementAt(4),astrSchYrInfo[2],(String)vStudInfo.elementAt(7),
			(String)vStudInfo.elementAt(8));
		if(vMaxLoadDetail == null)
		{
			bolFatalErr = true;
			strErrMsg = advising.getErrMsg();
		}
		else
		{
			strMaxAllowedLoad = (String)vMaxLoadDetail.elementAt(0);
			if(vMaxLoadDetail.size() > 1)
				strOverLoadDetail = "Maximum load in curriculum for this sem "+(String)vMaxLoadDetail.elementAt(1)+
				" overloaded load "+(String)vMaxLoadDetail.elementAt(0)+" (approved on :"+(String)vMaxLoadDetail.elementAt(2)+")";
		}
	}
	//Withdraw subject if it is trigged.
	if(!bolFatalErr && WI.fillTextValue("saveChanges").compareTo("1") ==0) {
		//change enrollment information.
		if(enrlAddDropSub.modifyEnrollment(dbOP, request))
			strErrMsg = "Enrollment information changes successfully.";
		else	
			strErrMsg = enrlAddDropSub.getErrMsg();
	
	}
	if(!bolFatalErr) // show enrolled list
	{
		//add "-" to stud index to get is_only_lab information.
		vEnrolledList = enrlAddDropSub.getEnrolledList(dbOP,(String)vStudInfo.elementAt(0)+"-",(String)vStudInfo.elementAt(9),
                                astrSchYrInfo[0],astrSchYrInfo[1],astrSchYrInfo[2]);
		if(vEnrolledList ==null) {
			strErrMsg = enrlAddDropSub.getErrMsg();
			bolFatalErr = true;
		}
	}
}
if(vStudInfo != null && vStudInfo.size() > 0) {
	strDegreeType = dbOP.mapOneToOther("course_offered", "course_index",
                                       (String)vStudInfo.elementAt(5), "degree_type",
                                       " and is_valid=1 and is_del=0");
	if(strDegreeType == null)
		strErrMsg = "Error in getting course degree type.";
}

%>

<form action="./re_assign_lec_lab.jsp" method="post" name="form_">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" >
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: CHANGE 
          OF LEC/LAB OR ENROLLED UNIT ::::</strong></font></strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="18%" height="25">Enter Student ID </td>
      <td width="18%" height="25"><input name="stud_id" type="text" size="16" value="<%=WI.getStrValue(strStudID)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td width="8%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="53%" height="25"><input type="image" src="../../../images/form_proceed.gif" border="0"></a>      </td>
    </tr>
    <tr>
      <td></td>
      <td colspan="4"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">School Year/Term </td>
      <td height="25" colspan="3"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp;&nbsp;&nbsp; <select name="semester" onChange="ReloadPage();">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
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
<% if(vStudInfo != null && vStudInfo.size() > 0 && !bolFatalErr){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr > 
      <td colspan="3" height="25"><hr size="1"></td>
    </tr>
    <tr > 
      <td width="3%" height="25">&nbsp;</td>
      <td width="14%" height="25">Student name </td>
      <td width="83%"> <strong><%=(String)vStudInfo.elementAt(1)%></strong> <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>"> 
      </td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">Course/Major</td>
      <td height="25"><strong><%=(String)vStudInfo.elementAt(2)%> 
        <%
		if(vStudInfo.elementAt(3) != null){%>
        / <%=(String)vStudInfo.elementAt(3)%> 
        <%}%>
        </strong></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td height="25">Year level</td>
      <td height="25"><strong><%=(String)vStudInfo.elementAt(4)%></strong> <input type="hidden" name="year_level" value="<%=(String)vStudInfo.elementAt(4)%>"></td>
    </tr>
    <tr > 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">SUBJECTS 
          ENROLLED</font></div></td>
    </tr>
    <%
if(strOverLoadDetail != null){%>
    <tr> 
      <td  height="25">&nbsp;</td>
      <td colspan="2" height="25"><font size="1">Overload detail : <%=strOverLoadDetail%></font></td>
    </tr>
    <%}%>
    <tr > 
      <td height="25">&nbsp;</td>
      <td  colspan="2" height="25">Maximum units the student can take : <strong><%=strMaxAllowedLoad%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="12%" height="27" align="center" class="thinborder"><font size="1"><strong>Subject Code </strong></font></td>
      <td width="20%" align="center" class="thinborder"><font size="1"><strong>Subject Title </strong></font></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>Lec/Lab Units </strong></font></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>Units Taken  
        </strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>Section</strong></font></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">Room # </font></strong></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>Schedule</strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>New Enrolled Unit </strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>Enrolled in? </strong></font></td>
      <td width="4%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Update</td>
    </tr>
    <%
 for(int i=1;i<vEnrolledList.size();++i,++j){ 
 	if( ((String)vEnrolledList.elementAt(i)).compareTo("0") == 0)//do not show any re-enrolled subject.
		continue;
	strTemp = (String)vEnrolledList.elementAt(i+1);
	if(strTemp == null) 
		strTemp = "";
	%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vEnrolledList.elementAt(i+3)%></td>
      <td class="thinborder"><%=(String)vEnrolledList.elementAt(i+4)%></td>
      <td class="thinborder"><%=(String)vEnrolledList.elementAt(i+11)%>/<%=(String)vEnrolledList.elementAt(i+12)%></td>
      <td class="thinborder"><%=(String)vEnrolledList.elementAt(i+13)%></td>
      <td class="thinborder"><%=WI.getStrValue(vEnrolledList.elementAt(i+7),"N/A")%></td>
      <td class="thinborder"><%=WI.getStrValue(vEnrolledList.elementAt(i+8),"N/A")%></td>
      <td class="thinborder"><%=WI.getStrValue(vEnrolledList.elementAt(i+6),"N/A")%> 
        <!-- all the hidden fileds are here. 
        <input type="hidden" name="enroll_i<%=j%>" value="<%=(String)vEnrolledList.elementAt(i)%>">-->      </td>
      <td align="center" class="thinborder"> <input type="text" name="unit_enrolled<%=j%>" value="<%=(String)vEnrolledList.elementAt(i+13)%>"
	  class="textbox" style="font-size:15px" onFocus="style.backgroundColor='#D3EBFF'" 
      onBlur="style.backgroundColor='white'" size="3" maxlength="3"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"></td>
      <td class="thinborder"> <select name="is_lab_only<%=j%>" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 9;"
	   onChange="document.form_.enroll_i<%=j%>.checked='true'">
          <option value="0">Lec and Lab</option>
          <%
	  if( vEnrolledList.elementAt(i+12) != null && 
	  	WI.getStrValue(vEnrolledList.elementAt(i+12),"0.0").compareTo("0.0") != 0){
		
	  if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Lab Only</option>
          <%}else{%>
          <option value="1">Lab Only</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>Lec Only</option>
          <%}else{%>
          <option value="2">Lec Only</option>
          <%}
	  }//show only if lab unit > 0 %>
        </select></td>
      <td class="thinborder" align="center"><input type="checkbox" name="enroll_i<%=j%>" value="<%=(String)vEnrolledList.elementAt(i)%>"></td>
    </tr>
    <%
i = i+13;
}%>
    <tr> 
      <td height="65" colspan="10" class="thinborder" align="center">
	  <%
	  if(iAccessLevel > 1) {%>
	  <a href="javascript:saveChanges();"><img src="../../../images/save.gif" border="0"></a>
	  <font size="1">click to modify enrollment information.</font>
	  <%}//only if authorized.%>	  </td>
    </tr>
  </table>
<%
}//only if student information is not null
%>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="saveChanges" value="0">
<input type="hidden" name="maxAllowedLoad" value="<%=strMaxAllowedLoad%>">
<input type="hidden" name="maxDisplay" value="<%=j%>">
<input type="hidden" name="degree_type" value="<%=strDegreeType%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>