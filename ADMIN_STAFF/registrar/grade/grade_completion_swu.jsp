<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
if(strSchCode == null)
	strSchCode = "";

boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	SetFields();
	document.form_.submit();
}
function SetFields()
{
	document.form_.grade_name.value= document.form_.grade_for[document.form_.grade_for.selectedIndex].text;
	document.form_.semester_name.value= document.form_.semester[document.form_.semester.selectedIndex].text;
}

function PrintForm(strGSIndex, strPrintType, strPrintBy, strPrintCount){

	if(strPrintType == "1" && strGSIndex.length == 0){
		alert("Please select subject for grade completion.");
		return;
	}
	
	var strSelected = "";
	var maxDisp = document.form_.item_count.value;
	
	if(strPrintType == "2"){
		for(var i =1; i< maxDisp; ++i){
			if(eval('document.form_.save_'+i+'.checked=='+true)){
				if(strSelected.length == 0)
					strSelected = eval('document.form_.save_'+i+'.value');
				else
					strSelected += ", "+eval('document.form_.save_'+i+'.value');
			}
		}
	}
	if(strPrintType == "1")
		strSelected = strGSIndex;
		
	if(strSelected.length == 0)	{
		alert("Please select atleast one subject for grade completion.");
		return;
	}
	
	var strPrintInfo = "";
	if(strPrintBy != "null" && strPrintBy.length > 0 && strPrintCount != "0")
		strPrintInfo = "Last Printed by : "+strPrintBy+" Count : "+strPrintCount+"\r\n";
	
	

	
	var strDueDate = document.form_.due_date.value;
	strDueDate = prompt(strPrintInfo+"Please enter completion due date in mm/dd/yyyy format",strDueDate);
	if(strDueDate.length == 0){
		alert("Please provide completion due date.");
		return;
	}
	
	document.form_.due_date.value = strDueDate;
	

	var printLoc = "./grade_completion_print.jsp?strSelectedGSIndex="+strSelected+
	"&completion_due_date="+strDueDate+
	"&semester="+document.form_.semester.value+
	"&sy_from="+document.form_.sy_from.value+
	"&swu_print_count="+strPrintCount+
	"&sy_to="+document.form_.sy_to.value;
	var win=window.open(printLoc,"PrintWindow",'width=900,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPage()
{
	var strSelected = "";
	var maxDisp = document.form_.item_count.value;
	
	for(var i =1; i< maxDisp; ++i)
		if(eval('document.form_.save_'+i+'.checked=='+true)){
			if(strSelected.length == 0)
				strSelected = eval('document.form_.save_'+i+'.value');
			else
				strSelected += ", "+eval('document.form_.save_'+i+'.value');
		}
	if(strSelected.length == 0)	{
		alert("Please select atleast one subject to print.");
		return;
	}
	
	var printLoc = "./grade_completion_slip_print.jsp?stud_id="+escape(document.form_.stud_id.value)+
		"&sy_from="+document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+
		"&grade_for="+escape(document.form_.grade_for[document.form_.grade_for.selectedIndex].value)+"&semester="+
		document.form_.semester[document.form_.semester.selectedIndex].value+"&sem_name="+
		escape(document.form_.semester[document.form_.semester.selectedIndex].text)+
		"&grade_name="+escape(document.form_.grade_name.value)+
		"&strSelectedGSIndex="+strSelected;

	
	var win=window.open(printLoc,"PrintWindow",'width=900,height=400,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function focusID() {
	document.form_.stud_id.focus();
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
function checkAllSaveItems() {
	var maxDisp = document.form_.item_count.value;
	var bolIsSelAll = document.form_.selAllSaveItems.checked;
	for(var i =1; i< maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}
</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Completion","grade_completion_swu.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Completion",request.getRemoteAddr(),
									null);

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


GradeSystem GS = new GradeSystem();
FAPaymentUtil pmtUtil = new FAPaymentUtil();

String strUserIndex   = null;


//get student information first before getting grade details.
Vector vStudInfo =  pmtUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
String strRemark  = null;
String strCurHistIndex = null;
boolean bolContainsINE = false;
Vector vGradeDetail = null;

Vector vRemarks = new Vector();
vRemarks.addElement("inr");
vRemarks.addElement("ine");
vRemarks.addElement("inc");
vRemarks.addElement("incomplete");
vRemarks.addElement("inp");

if(vStudInfo == null)
	strErrMsg = pmtUtil.getErrMsg();
else
{

	vGradeDetail = GS.gradeReleaseForAStud(dbOP,(String)vStudInfo.elementAt(0),request.getParameter("grade_for"),request.getParameter("sy_from"),
		request.getParameter("sy_to"),request.getParameter("semester"),true,true,true);//get all information.
	strUserIndex = (String)vStudInfo.elementAt(0);
	if(vGradeDetail == null)
		strErrMsg = GS.getErrMsg();
	else{				
		
		for(int i=0; i< vGradeDetail.size(); i += 8){
			strRemark  = WI.getStrValue(vGradeDetail.elementAt(i+6),"&nbsp;");		
			//if(strRemark.toLowerCase().indexOf("inc") == -1 && strRemark.toLowerCase().indexOf("inr") == -1 && strRemark.toLowerCase().indexOf("ine") == -1)
			if(vRemarks.indexOf(strRemark.toLowerCase()) == -1)
				continue;			
			bolContainsINE = true;
			break;
		}
		
		if(!bolContainsINE){
			vGradeDetail = new Vector();
			strErrMsg = "Grades for completion data not found.";
		}
		
	}
}
if(strErrMsg == null) strErrMsg = "";

%>

<form name="form_" action="./grade_completion_swu.jsp" method="post">
<input type="hidden" name="grade_name" value="0">
<input type="hidden" name="semester_name" value="0">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6" align="center"><font color="#FFFFFF"><strong>::::
        GRADE COMPLETION PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="5" ><strong><%=strErrMsg%></strong></td>
    </tr>

    <tr valign="top">
      <td width="2%" height="25" >&nbsp;</td>
      <td width="30%" height="25" >Student ID: &nbsp; 
	  <input name="stud_id" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeyUp="AjaxMapName('1');" value="<%=WI.fillTextValue("stud_id")%>" size="16">      </td>
      <td width="5%" ><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="11%" ><input type="image" src="../../../images/form_proceed.gif">      </td>
      <td width="49%" ><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
      <td width="3%" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="6" height="25" >
	  
	  <hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="2" >Student name : <strong><%=(String)vStudInfo.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="2" >Course/Major : <strong><%=(String)vStudInfo.elementAt(2)%>
        <%=WI.getStrValue((String)vStudInfo.elementAt(3),"/","","")%></strong></td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td width="30%" height="25" >Year : <strong><%=WI.getStrValue(vStudInfo.elementAt(4),"N/A")%></strong></td>
      <td width="68%" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3" height="25" ><hr size="1"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" width="2%" >&nbsp;</td>
<%
	
	strTemp  = " from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 and exam_name like 'final%' order by EXAM_PERIOD_ORDER asc"; 
%>
	  
      <td width="51%" height="25" > Show&nbsp; 
        <select name="grade_for" onChange="ReloadPage();">
          <%=dbOP.loadCombo("EXAM_NAME","EXAM_NAME",strTemp, request.getParameter("grade_for"), false)%>
        </select>        grades for term &nbsp;
        <select name="semester" onChange="ReloadPage();">
          <option value="1">1st Semester</option>
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) {
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	if(strTemp == null)
		strTemp = "";
}
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Semester</option>
          <%}else{%>
          <option value="2">2nd Semester</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Semester</option>
          <%}else{%>
          <option value="3">3rd Semester</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select> </td>
      <td width="32%" height="25" >School year :
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>

        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
      <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
      <td width="15%" ><input type="image" src="../../../images/form_proceed.gif"></td>
    </tr>

    <tr >
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
</table>

<%


if(vGradeDetail != null && vGradeDetail.size() > 0 && bolContainsINE){%>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >       
      <td align="right" height="25"><a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">Click to print application for completion(white form)</font>	  </td>
    </tr>
  </table>


 <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td width="11%" height="25" align="center" class="thinborder" ><font size="1"><strong>Subject Code </strong></font></td>
      <td width="31%" align="center" class="thinborder" ><font size="1"><strong>Subject Name </strong></font></td>
      <td width="4%" align="center" class="thinborder"><font size="1"><strong>Credit</strong></font></td>
      <td width="24%" align="center" class="thinborder"><font size="1"><strong>Instructor</strong></font></td>
      <td width="6%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">Grade<font size="1"><strong> </strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>Remarks</strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>Print<br>
	  <input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();">
	  </strong></font></td>
      <td width="8%" align="center" class="thinborder">&nbsp;</td>
    </tr>
<%

String strGradeReference = null;
String strGrade   = null;
String strCEarned = null;

java.sql.ResultSet rs = null;
			
strTemp = 	
	" select s_index, fname, mname, lname  "+
	" from G_SHEET_FINAL  "+
	" join FACULTY_LOAD on (FACULTY_LOAD.SUB_SEC_INDEX = G_SHEET_FINAL.SUB_SEC_INDEX) "+
	" join USER_TABLE on (USER_TABLE.USER_INDEX = FACULTY_LOAD.USER_INDEX) "+
	" where FACULTY_LOAD.IS_VALID = 1 "+
	" and IS_MAIN = 1 "+
	" and GS_INDEX = ? ";	
java.sql.PreparedStatement pstmtSelect = dbOP.getPreparedStatement(strTemp);

	
strTemp = 
	" select distinct COMPLETION_PRINT_COUNT, fname, mname, lname, COMPLETION_PRINT_DATE "+
	" from g_sheet_final "+
	" join user_table on (user_table.user_index = COMPLETION_PRINT_BY) where gs_index = ? ";
java.sql.PreparedStatement pstmtSelectPrintInfo = dbOP.getPreparedStatement(strTemp);


int iCount = 1;
String strPrintBy = null;
String strPrintDate = null;
int iPrintCount = 0;
for(int i=0; i< vGradeDetail.size(); i += 8){
strRemark  = WI.getStrValue(vGradeDetail.elementAt(i+6),"&nbsp;");
//if(strRemark.toLowerCase().indexOf("inc") == -1 && strRemark.toLowerCase().indexOf("inr") == -1 && strRemark.toLowerCase().indexOf("ine") == -1)
if(vRemarks.indexOf(strRemark.toLowerCase()) == -1)
	continue;
	
/*if(vGradeDetail.elementAt(i) == null)
	continue;*/
				
pstmtSelect.setString(1, (String)vGradeDetail.elementAt(i));
rs = pstmtSelect.executeQuery();
if(rs.next()){
	strTemp = GS.getLoadingForSubject(dbOP, rs.getString(1));
	vGradeDetail.setElementAt(strTemp, i + 3);
	strTemp = WebInterface.formatName(rs.getString(2),rs.getString(3),rs.getString(4),4);
	vGradeDetail.setElementAt(strTemp, i + 4);
}rs.close();


strPrintBy = null;
strPrintDate = null;
iPrintCount = 0;
pstmtSelectPrintInfo.setString(1,(String)vGradeDetail.elementAt(i));
rs = pstmtSelectPrintInfo.executeQuery();
if(rs.next()){
	iPrintCount = rs.getInt(1);
	strPrintDate = ConversionTable.convertMMDDYYYY(rs.getDate(5));
	strPrintBy = WebInterface.formatName(rs.getString(2),rs.getString(3), rs.getString(4),4)+WI.getStrValue(strPrintDate," (",")","");	
}rs.close();

strGradeReference = (String)vGradeDetail.elementAt(i);
strGrade   = (String)vGradeDetail.elementAt(i+5);
strCEarned = WI.getStrValue(vGradeDetail.elementAt(i+3),"&nbsp;");



%>
    <tr title="<%=strGradeReference%>">
      <td  height="25" class="thinborder" >&nbsp;<%=(String)vGradeDetail.elementAt(i + 1)%></td>
      <td class="thinborder" >&nbsp;<%=((String)vGradeDetail.elementAt(i+2)).toUpperCase()%></td>
      <td align="center" class="thinborder"><%=strCEarned%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vGradeDetail.elementAt(i+4),"n/f")%></td>
      <td align="center" class="thinborder" <%=strTemp%>><%=strGrade%></td>
      <td align="center" class="thinborder" ><%=strRemark%></td>
      <td align="center" class="thinborder" ><input type="checkbox" name="save_<%=iCount++%>" value="<%=(String)vGradeDetail.elementAt(i)%>"></td>
      <td align="center" class="thinborder" >
	  	<a href="javascript:PrintForm('<%=(String)vGradeDetail.elementAt(i)%>','1','<%=strPrintBy%>','<%=iPrintCount%>');"><img src="../../../images/print.gif" border="0"></a>
	  </td>
    </tr>
<%}%>
<input type="hidden" name="item_count" value="<%=iCount%>">
  </table>
  
    <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr >       
	<%
	if(iCount > 2)// 2 if there is only 1 INE,INC, INR gradelawful
		strTemp = "";
	else
		strTemp = Integer.toString(iPrintCount);
	%>
      <td align="right" height="25">
	  <a href="javascript:PrintForm('','2','','<%=strTemp%>');"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">Click to print grade completion(yellow form)</font>	  </td>
    </tr>
  </table>

<%
	}
}//only if vStudInfo is not null.
%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="due_date" value="<%=WI.fillTextValue("due_date")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
