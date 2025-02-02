<%@ page language="java" import="utility.*,health.RecordHealthInformation,java.util.Vector " %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.bgColor = "#FFFFFF";
	var obj = document.getElementById('myADTable1');
	
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	
	obj = document.getElementById('myADTable2');
	obj.deleteRow(0);
	obj.deleteRow(0);

	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function viewList(table,indexname,colname,labelname){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" +
	colname+"&label="+labelname+"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
	document.form_.stud_id.focus();
}
function StudSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function EmpSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function AjaxMapName(strPos) {
		var strCompleteName;
			strCompleteName = document.form_.stud_id.value;

		if(strCompleteName.length <=2)
			return;

		var objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName)+ "&is_faculty=1";
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.form_.stud_id.focus();
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {

}
function UpdateNameFormat(strName) {
	//do nothing..
}
</script>
<body onLoad="FocusID();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;

	boolean bolNoRecord = true; //it is false if there is error in edit info.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-FAMILY HISTORY","family_history_entry.jsp");
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
														"Health Monitoring","FAMILY HISTORY",request.getRemoteAddr(),
														"family_history_entry.jsp");
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
Vector vBasicInfo = null;Vector vHealthInfo = null;Vector vAdditionalInfo = null;
boolean bolIsStaff = false;
boolean bolIsStudEnrolled = false;//true only if enrolled to current sy / sem.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
RecordHealthInformation RH = new RecordHealthInformation();

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {//called for adde,edit or delete.

}
//get all levels created.
if(WI.fillTextValue("stud_id").length() > 0) {
	if(bolIsSchool) {
		vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
		if(vBasicInfo == null) //may be it is the teacher/staff
		{
			request.setAttribute("emp_id",request.getParameter("stud_id"));
			vBasicInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
			if(vBasicInfo != null)
				bolIsStaff = true;
		}
		else {//check if student is currently enrolled
			Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"),
			(String)vBasicInfo.elementAt(10),(String)vBasicInfo.elementAt(11),(String)vBasicInfo.elementAt(9));
			if(vTempBasicInfo != null)
				bolIsStudEnrolled = true;
		}
		if(vBasicInfo == null)
			strErrMsg = OAdm.getErrMsg();
	}
	else{//check faculty only if not school...
			request.setAttribute("emp_id",request.getParameter("stud_id"));
			vBasicInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
			if(vBasicInfo != null)
				bolIsStaff = true;
			if(vBasicInfo == null)
				strErrMsg = "Employee Information not found.";;
	}
}
//gets health info.
if(vBasicInfo!= null) {
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		//I have to add / edit here.
		if(RH.operateOnFamilyHealthInfo(dbOP, request,1) == null)
			strErrMsg = RH.getErrMsg();
		else
			strErrMsg = "Health Record successfully updated.";
	}
	vHealthInfo = RH.operateOnFamilyHealthInfo(dbOP, request,4);
	if(vHealthInfo == null)
		strErrMsg = RH.getErrMsg();
	else {//System.out.println(vHealthInfo);
	vAdditionalInfo = (Vector)vHealthInfo.elementAt(0);
	if(vAdditionalInfo.size() ==0)
		vAdditionalInfo = null;

	}
}

%>
<form action="./family_history_rec.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr >
      <td height="28" colspan="6" bgcolor="#697A8F" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          FAMILY HISTORY RECORD VIEW PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr >
      <td width="2%"  >&nbsp;</td>
      <td width="15%" >Enter ID No. :</td>
      <td width="20%" ><input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      
	  </td>
      <td colspan="2" ><%if(bolIsSchool){%>
        <a href="javascript:StudSearch();"><img src="../../../images/search.gif" border="0" ></a> <font size="1">Click to search for student </font>
        <%}%>
        <a href="javascript:EmpSearch();"><img src="../../../images/search.gif" border="0" ></a><font size="1"> Click to search for employee </font>
		<label id="coa_info" style="font-size:11px;"></label>
		</td>
      <td width="3%" valign="top" >&nbsp;</td>
    </tr>
    <tr >
      <td width="2%">&nbsp;</td>
      <td width="15%">&nbsp;</td>
      <td width="20%"><input name="image" type="image" src="../../../images/form_proceed.gif"></td>
      <td width="21%" >&nbsp;</td>
      <td width="39%" align="right" style="font-size:9px;">
	  <%if(vAdditionalInfo != null) {%>
	  	<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
		Print page.
	  <%}%>
	  </td>
      <td width="3%">&nbsp;</td>
    </tr>
<%if(vAdditionalInfo != null){%>
    <tr >
      <td colspan="6" style="font-size:11px; font-weight:bold;" align="center"><u>FAMILY HISTORY  HEALTH RECORD </u></td>
    </tr>
 <tr >
      <td >&nbsp;</td>
      <td >Date Recorded: </td>
      <td colspan="2"  height="25"><%=vAdditionalInfo.elementAt(0)%></td>
      <td valign="top" ><%if(vAdditionalInfo!= null){%>
        <table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td><font size="1">
              Record Last Updated :
              <%if(vAdditionalInfo != null){%>
              <%=(String)vAdditionalInfo.elementAt(2)%>
              <%}%>
              <br>
              <br>
              </font><font size="1">Updated by :
                <%if(vAdditionalInfo != null){%>
                <%=(String)vAdditionalInfo.elementAt(3)%>
                <%}%>
              </font></td>
          </tr>
        </table>
      <%}%></td>
      <td valign="top" >&nbsp;</td>
    </tr>
<%}%>
    <tr >
      <td height="18" colspan="6" ><hr size="1"></td>
    </tr>
  </table>

  <%
if(vBasicInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%
if(!bolIsStaff){%>
    <tr >
      <td  width="2%" height="25">&nbsp;</td>
      <td width="15%" >Student Name : </td>
      <td width="46%" ><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></td>
      <td width="13%" >Status : </td>
      <td width="24%" >
        <%if(bolIsStudEnrolled){%>
        Currently Enrolled
        <%}else{%>
        Not Currently Enrolled
        <%}%>
      </td>
    </tr>
    <tr>
      <td   height="25">&nbsp;</td>
      <td >Course/Major :</td>
      <td height="25" colspan="3" ><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Year :</td>
      <td ><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></td>
      <td >&nbsp;</td>
      <td >&nbsp;</td>
    </tr>
    <%}//if not staff
else{%>
    <tr >
      <td height="25">&nbsp;</td>
      <td >Emp. Name :</td>
      <td ><%=WebInterface.formatName((String)vBasicInfo.elementAt(1),
	  (String)vBasicInfo.elementAt(2),(String)vBasicInfo.elementAt(3),4)%></td>
      <td >Emp. Status :</td>
      <td ><strong><%=(String)vBasicInfo.elementAt(16)%></strong></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
      <td ><%if(bolIsSchool){%>College/Office<%}else{%>Division<%}%> :</td>
      <td > <strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/ <%=WI.getStrValue(vBasicInfo.elementAt(14))%></strong></td>
      <td >Designation :</td>
      <td ><strong><%=(String)vBasicInfo.elementAt(15)%></strong></td>
    </tr>
    <%}//only if staff %>
  </table>
<%}///only if vBasicInfo is not null
if(vHealthInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFF9F" >
      <td width="25%" height="25" class="thinborder">&nbsp;</td>
      <td width="7%" class="thinborder"><div align="center"><strong>Yes</strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>No</strong></div></td>
      <td width="61%" class="thinborder"><div align="center"><strong>Specify Relationship</strong></div></td>
    </tr>
    <%
int j = 0 ;
for(int i = 1 ; i < vHealthInfo.size(); i += 4, ++j){%>
    <input type="hidden" name="HM_ENTRY_INDEX<%=j%>" value="<%=(String)vHealthInfo.elementAt(i)%>">
    <tr  >
      <td height="25" class="thinborder"><%=(String)vHealthInfo.elementAt(i + 1)%></td>
      <td align="center" class="thinborder"> <%
strTemp = WI.getStrValue((String)vHealthInfo.elementAt(i + 2), "0");
if(strTemp.compareTo("1") ==0)
	strTemp = " checked";
else
	strTemp = "";

if(strTemp.length() > 0){%>
        <img src="../../../images/tick.gif">
        <%}%>
        &nbsp;</td>
      <td align="center" class="thinborder"> <%if(strTemp.length() == 0){%>
        <img src="../../../images/tick.gif">
        <%}%>
        &nbsp;</td>
      <td class="thinborder"><%=RH.getRelationList(dbOP, (String)vHealthInfo.elementAt(i + 3), j, true)%>&nbsp;</td>
    </tr>
    <%}//end of for loop%>
    <input type="hidden" name="health_record_count" value="<%=j%>">
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr valign="bottom"  >
      <td height="30" colspan="4"><u><b>Comments/Remarks : </b></u></td>
    </tr>
    <tr  >
      <td height="30" colspan="4"> <%if(vAdditionalInfo != null){%><%=WI.getStrValue(vAdditionalInfo.elementAt(1),"None")%><%}%></td>
    </tr>
  </table>
<%}//only if vHealthInfo is not null%>

  <table  width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr >
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
