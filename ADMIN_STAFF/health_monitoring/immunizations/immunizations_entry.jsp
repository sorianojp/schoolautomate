<%@ page language="java" import="utility.*, health.Immunization, java.util.Vector " %>
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
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script language="JavaScript">
<!--
function PageAction(strAction, strInfoIndex) {
	document.form_.print_page.value="";
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.print_page.value="";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce('form_');
}
function Cancel()
{
	document.form_.print_page.value="";
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
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
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond){
var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +"&opner_form_name=form_";

	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function  FocusID() {
	document.form_.stud_id.focus();
}
function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?is_faculty=-1&methodRef=2&search_id=1&name_format=4&complete_name="+
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
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEditInfo = null;

	if (WI.fillTextValue("print_page").length() > 0){ %>
		<jsp:forward page="./immunizations_entry_print.jsp"/>
	<% return;}

	String strInfoIndex = null;
	String strPrepareToEdit = null;
	int iTemp = 0;
	String strErrMsg = null;
	String strTemp = null;

	String [] astrComplied = {"Not Complied", "Complied"};
	String [] astrInterval = {"Day(s)", "Week(s)", "Month(s)", "Year(s)"};

	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	int iSearchResult = 0;

	boolean bolNoRecord = true; //it is false if there is error in edit info.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Immunizations","immunizations_entry.jsp");
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
														"Health Monitoring","Immunizations",request.getRemoteAddr(),
														"immunizations_entry.jsp");
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
Vector vBasicInfo = null;
boolean bolIsStaff = false;
boolean bolIsStudEnrolled = false;//true only if enrolled to current sy / sem.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();

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



	Immunization immune = new Immunization();
	strTemp = WI.fillTextValue("page_action");

	if(strTemp.length() > 0) {
		if(immune.operateOnImmunization(dbOP, request, Integer.parseInt(strTemp)) != null ) {
				strErrMsg = "Operation successful.";
				strPrepareToEdit = "";
				}
		else
				strErrMsg = immune.getErrMsg();
	}

	if(strPrepareToEdit.compareTo("1") == 0) {
    	vEditInfo = immune.operateOnImmunization(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null )
			strErrMsg = immune.getErrMsg();
	}

	vRetResult = immune.operateOnImmunization(dbOP, request, 4);
	iSearchResult = immune.getSearchCount();
	if (strErrMsg == null && WI.fillTextValue("stud_id").length()>0)
		strErrMsg = immune.getErrMsg();
%>
<body bgcolor="#8C9AAA" onLoad="FocusID();" class="bgDynamic">
<form action="./immunizations_entry.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F">
      <td height="28" colspan="6" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      IMMUNIZATIONS - ADD/UPDATE RECORD ENTRY PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" colspan="6" bgcolor="#FFFFFF"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td width="2%"  height="28" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="15%" height="28" bgcolor="#FFFFFF">Enter ID No. :</td>
      <% if (vEditInfo!= null && vEditInfo.size()>0)
            strTemp = (String)vEditInfo.elementAt(8);
      	else
      		strTemp = WI.fillTextValue("stud_id");%>
      <td width="16%" height="28" bgcolor="#FFFFFF">
      <input type="text" name="stud_id" class="textbox"
      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" onKeyUp="AjaxMapName('1');">      </td>
      <td width="25%" height="28" bgcolor="#FFFFFF">
	  <%if(bolIsSchool){%>
	  <a href="javascript:StudSearch();"><img src="../../../images/search.gif" border="0" ></a><font size="1">Search for student</font>
	  <%}%>	  </td>
      <td width="39%" rowspan="3" valign="top" bgcolor="#FFFFFF"> <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#B0B0FF">
          <tr>
            <td><font size="1"><br>
              Record Last Updated :<br>
              <br>
              </font><font size="1">Updated by : <br>
              <br>
              </font></td>
          </tr>
        </table></td>
      <td width="3%" valign="top" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="28" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="28" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="28" bgcolor="#FFFFFF"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td height="28" bgcolor="#FFFFFF"><a href="javascript:EmpSearch();"><img src="../../../images/search.gif" border="0" ></a><font size="1">Search for employee</font></td>
      <td valign="top" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="28" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="28" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="28" colspan="2" bgcolor="#FFFFFF"><label id="coa_info" style="font-size:11px;"></label></td>
      <td valign="top" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="18" colspan="6" bgcolor="#FFFFFF"><hr size="1"></td>
    </tr>
  </table>
<%
if(vBasicInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<% if(!bolIsStaff){%>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="15%" >Student Name : </td>
      <td width="46%" ><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></td>
      <td width="13%" >Status : </td>
      <td width="24%" > <%if(bolIsStudEnrolled){%>
        Currently Enrolled <%}else{%>
        Not Currently Enrolled <%}%></td>
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
      <td > <strong><%=WI.getStrValue(vBasicInfo.elementAt(13))%>/
	  <%=WI.getStrValue(vBasicInfo.elementAt(14))%></strong></td>
      <td >Designation :</td>
      <td ><strong><%=(String)vBasicInfo.elementAt(15)%></strong></td>
    </tr>
    <%}//only if staff %>
   <tr>
      <td height="18" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F">
      <td  width="2%"height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="20%" height="25" bgcolor="#FFFFFF">Immunization name:</td>
      <td height="25" colspan="2" bgcolor="#FFFFFF">
<% if (vEditInfo!= null && vEditInfo.size()>0)
        strTemp = (String)vEditInfo.elementAt(9);
  	else
  		strTemp = WI.fillTextValue("immun_name_index");%>
      <select name="immun_name_index">
          <option value="">Select Immunization</option>
			<%=dbOP.loadCombo("IMMUN_NAME_INDEX","IMMUN_NAME"," FROM HM_PRELOAD_IMMUNIZATION ORDER BY IMMUN_NAME", strTemp, false)%>
        </select>
<%if(iAccessLevel > 1){%>
		<font size="1"><a href='javascript:viewList("HM_PRELOAD_IMMUNIZATION","IMMUN_NAME_INDEX","IMMUN_NAME","VACCINES",
	"HM_IMMUNIZATION","IMMUN_NAME_INDEX", " and HM_IMMUNIZATION.IS_DEL = 0 AND HM_IMMUNIZATION.IS_VALID = 1","")'><img src="../../../images/update.gif" border="0"></a><font size="1">click
        to update list of Immunization names</font>
        <%}%>
	  </td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="25" bgcolor="#FFFFFF">Required Dosage</td>
      <td height="25" colspan="2" bgcolor="#FFFFFF">
<% if (vEditInfo!= null && vEditInfo.size()>0)
        strTemp = (String)vEditInfo.elementAt(2);
   	else
  		strTemp = WI.fillTextValue("req_dose"); %>
			<input name="req_dose" type="text" class="textbox" value="<%=strTemp%>" size="3" maxlength="3"
 		onKeyUp= 'AllowOnlyInteger("form_","req_dose")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","req_dose");style.backgroundColor="white"'></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="25" bgcolor="#FFFFFF">Dosage Taken</td>
      <td height="25" colspan="2" bgcolor="#FFFFFF">
<%if (vEditInfo!= null && vEditInfo.size()>0)
        strTemp = (String)vEditInfo.elementAt(3);
	else
    	strTemp = WI.fillTextValue("take_dose"); %>
			<input name="take_dose" type="text" class="textbox" value="<%=strTemp%>" size="3" maxlength="3"
 		onKeyUp= 'AllowOnlyInteger("form_","take_dose")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","take_dose");style.backgroundColor="white"' >      </td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="25" bgcolor="#FFFFFF">Last Date Taken</td>
      <td height="25" colspan="2" bgcolor="#FFFFFF">
<% if (vEditInfo!= null && vEditInfo.size()>0)
		strTemp = (String)vEditInfo.elementAt(4);
	else
      	strTemp = WI.fillTextValue("last_take");%>
      <input name="last_take" type="text" class="textbox" size="10" maxlength="10" value="<%=strTemp%>" readonly="yes">
			<a href="javascript:show_calendar('form_.last_take');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="25" bgcolor="#FFFFFF">Interval of Dosage</td>
      <td height="25" colspan="2" bgcolor="#FFFFFF">
<% if (vEditInfo!= null && vEditInfo.size()>0)
		strTemp = (String)vEditInfo.elementAt(5);
	else
		strTemp = WI.fillTextValue("interval");%>
		<input name="interval" type="text" class="textbox" value="<%=strTemp%>" size="3" maxlength="3"
 		onKeyUp= 'AllowOnlyInteger("form_","interval")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","interval");style.backgroundColor="white"' >
<% if (vEditInfo!= null && vEditInfo.size()>0)
		strTemp = (String)vEditInfo.elementAt(6);
	else
		strTemp = WI.fillTextValue("interval_unit");%>
        <select name="interval_unit">
          <%if (strTemp.compareTo("0")==0){%>
	           <option value="0" selected>day(s)</option>
	       <%}else{%>
	         <option value="0">day(s)</option>
	          <%} if (strTemp.compareTo("1")==0){%>
		           <option value="1" selected>week(s)</option>
	       <%}else{%>
                  <option value="1">week(s)</option>
    		 <%} if (strTemp.compareTo("2")==0){%>
		           <option value="2" selected>month(s)</option>
	       <%}else{%>
                  <option value="2">month(s)</option>
    		 <%} if (strTemp.compareTo("3")==0){%>
		         <option value="3" selected>year(s)</option>
	       <%}else{%>
                  <option value="3">year(s)</option>
    		<%}%>
        </select></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="46" bgcolor="#FFFFFF">&nbsp;</td>
      <td height="46" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="54%" height="46" bgcolor="#FFFFFF"><font size="1">
	  <%
	  if(iAccessLevel > 1) {
	  if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>
        Click to add entry
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a>
        Click to edit event <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>
        Click to clear entries
        <%}
	}%></font></td>
      <td width="27%" bgcolor="#FFFFFF"></td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="10" ><div align="right"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a><font size="1">click
        to print record</font></div></td>
    </tr>
    <tr >
      <td height="25" colspan="10" bgcolor="#FFFF9F" class="thinborderALL"><div align="center"><strong>LIST
          OF IMMUNIZATIONS TAKEN</strong></div></td>
    </tr>
    <tr bgcolor="#FFFFFF" >
      <td width="30%" height="25" class="thinborder"><div align="center"><font size="1"><strong>IMMUNIZATION
          NAME</strong></font></div></td>
      <td width="6%" class="thinborder"> <div align="center"><font size="1"><strong>DOSAGE REQUIRED</strong></font></div></td>
      <td width="6%" class="thinborder"><div align="center"><font size="1"><strong>DOSAGE TAKEN</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>LAST DATE TAKEN</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">DOSAGE INTERVAL</font></strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong><font size="1">NEXT DOSAGE SCHEDULE</font></strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>STATUS</strong></font></div></td>
      <td width="14%" class="thinborder" colspan="2">&nbsp;</td>
    </tr>
<%for (int i = 0; i< vRetResult.size(); i+=11){%>
    <tr bgcolor="#FFFFFF" >
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+5)%>&nbsp; <%=astrInterval[Integer.parseInt((String)vRetResult.elementAt(i+6))]%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%if (((String)vRetResult.elementAt(i+7)).compareTo("0")==0){%><%=(String)vRetResult.elementAt(i+10)%><%}else{%>&nbsp;<%}%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=astrComplied[Integer.parseInt((String)vRetResult.elementAt(i+7))]%></font></div></td>
      <td width="7%" class="thinborder"><font size="1">
        <% if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
        <%}else{%>
        Not authorized to edit
        <%}%>
        </font></td>
      <td width="7%" class="thinborder"><font size="1"> <% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        Not authorized to delete
        <%}%></font></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
      <td height="10">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
