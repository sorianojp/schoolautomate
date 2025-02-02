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
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script language="JavaScript">
<!--
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function Cancel()
{
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
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEditInfo = null;

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
<body onLoad="javascript:window.print();">
<form name="form_">
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
  <%if (vRetResult != null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr >
      <td height="25" colspan="8" class="thinborderALL"><div align="center"><strong>LIST
          OF IMMUNIZATIONS TAKEN</strong></div></td>
    </tr>
    <tr bgcolor="#FFFFFF" >
      <td width="30%" height="25" align="center" class="thinborder"><font size="1"><strong>IMMUNIZATION
          NAME</strong></font></td>
      <td width="6%" align="center" class="thinborder"> <font size="1"><strong>DOSAGE REQUIRED</strong></font></td>
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>DOSAGE TAKEN</strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>LAST DATE TAKEN</strong></font></td>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">DOSAGE INTERVAL</font></strong></td>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">NEXT DOSAGE SCHEDULE</font></strong></td>
      <td width="13%" align="center" class="thinborderBOTTOMLEFTRIGHT"><font size="1"><strong>STATUS</strong></font></td>
    </tr>
<%for (int i = 0; i< vRetResult.size(); i+=11){%>
    <tr bgcolor="#FFFFFF" >
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(i+5)%>&nbsp; <%=astrInterval[Integer.parseInt((String)vRetResult.elementAt(i+6))]%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%if (((String)vRetResult.elementAt(i+7)).compareTo("0")==0){%><%=(String)vRetResult.elementAt(i+10)%><%}else{%>&nbsp;<%}%></font></div></td>
      <td class="thinborderBOTTOMLEFTRIGHT"><div align="center"><font size="1"><%=astrComplied[Integer.parseInt((String)vRetResult.elementAt(i+7))]%></font></div></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
