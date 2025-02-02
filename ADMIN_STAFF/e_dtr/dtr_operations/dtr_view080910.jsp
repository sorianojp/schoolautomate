<%@page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil, 
												eDTR.AllowedLateTimeIN, java.util.Date, eDTR.ApplicationFix" buffer="16kb"%>
<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").equals("1"))
{ %>
	<jsp:forward page="./dtr_print.jsp" />
<%}

///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(7);

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
  Vector vRetEDTR = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	int iSearchResult =0;
	int iIndex = 0;
	String strMinUnwork = null;
	boolean bolOnlyLateUT = WI.fillTextValue("only_late_ut").equals("1");
	int iColCount = 11;
	if(bolOnlyLateUT)
		iColCount = 5;
	boolean bolHasTeam = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Print DTR","dtr_view.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"dtr_view.jsp");
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
if(strErrMsg == null) strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","5"};

ReportEDTR RE = new ReportEDTR(request);
AllowedLateTimeIN allowedLateTIN = new AllowedLateTimeIN();
ApplicationFix AppFix = new ApplicationFix();
Vector vSummaryWrkHours = null;
Vector vHoursWork = null;
Vector vDayInterval = null;
Vector vDayIntervalTemp = null;
Vector vHoursOT = null;
Vector vAdjustedEdtr = null;
Vector vAWOLRecords = null;
String strDateFr = null;
String strDateTo = null;
int iDateFormat = 2;
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};
Date odDate = null;
int iIncr = 1;

	int iAllowedLateAm = 0;
	int iAllowedLatePm = 0;
	Vector vLateTimeIn = null;
	vLateTimeIn = allowedLateTIN.operateOnLateSetting(dbOP, request, 3);

// use for checking only... if login name is bricks... it would also show date
if(((String)request.getSession(false).getAttribute("userId")).equals("bricks"))
	iDateFormat = 4;
	

if (WI.fillTextValue("viewRecords").equals("1")) {
	AppFix.removeDuplicateDtrEntries(dbOP,request);
	vRetResult = RE.searchEDTR(dbOP, false, true);

	if (vRetResult == null)
		strErrMsg = RE.getErrMsg();

//added by biswa to get from and to date.
	if( WI.fillTextValue("DateDefaultSpecify").equals("0")) {
		String[] astrTemp = eDTRUtil.getCurrentCutoffDateRange(dbOP, true);
		if(astrTemp != null) {
			strDateFr = astrTemp[0];
			strDateTo = astrTemp[1];
		}
	}
	else {
		strDateFr = WI.fillTextValue("from_date");
		strDateTo = WI.fillTextValue("to_date");
	}

	if (WI.fillTextValue("SummaryDetail").equals("1")){
		vDayIntervalTemp = RE.getDayNDateDetail(strDateFr,strDateTo);

		if (vDayInterval == null)
			strErrMsg = RE.getErrMsg();
	}

}
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function goToNextSearchPage(){
	ViewRecords();
	document.dtr_op.submit();
}
function ReloadPage()
{
	document.dtr_op.print_page.value="";

	document.dtr_op.reloadpage.value="1";
//	document.dtr_op.viewRecords.value ="1";
	document.dtr_op.submit();
}
function ViewDTR(strEmpID,strDateFrom, strDateTo)
{
//popup window here.
	var pgLoc = "./dtr_view.jsp?DateDefaultSpecify=1&SummaryDetail=1" +
	"&window_opener=1&viewRecords=1&view_one=1&emp_id="
	+escape(strEmpID)+"&from_date="+escape(strDateFrom)+"&to_date="+escape(strDateTo);

	var win=window.open(pgLoc,"EditWindow",'dependent=yes,width=750,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewRecords()
{
	document.dtr_op.print_page.value="";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
}

function PrintPage()
{

<%if (!WI.fillTextValue("view_one").equals("1")){%>
	document.dtr_op.print_page.value="1";
	document.dtr_op.viewRecords.value="1";
//	document.dtr_op.reloadpage.value="1";
	document.dtr_op.submit();
<%}else{%>
	//document.getElementById("header_").deleteRow(0);
	//document.getElementById("footer_").deleteRow(0);
	//document.getElementById("footer_").deleteRow(0);
	//document.getElementById("print_table").deleteRow(0);
	//document.getElementById("print_table").deleteRow(0);
	window.print();
<%}%>
}
function GoToNewReport() {
	location = "./dtr_view_new.jsp";
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.dtr_op.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.dtr_op.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.dtr_op.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function OnFieldfocus(strFieldName){
	document.getElementById(strFieldName).style.backgroundColor ='#AAAAAA';
}
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="dtr_op" action="./dtr_view.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="header_">
<% if (!WI.fillTextValue("view_one").equals("1")){%>
    <tr bgcolor="#A49A6A">
      <td height="25" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      DTR OPERATIONS - VIEW/PRINT DTR PAGE ::::</strong></font></td>
    </tr>
<%}%>
    <tr bgcolor="#FFFFFF">
      <td height="25" ><strong><font color="#FF0000" size="3">&nbsp;<%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
<% if (!WI.fillTextValue("view_one").equals("1")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24" colspan="2">&nbsp;<input type="checkbox" name="show_new" value="1" onClick="GoToNewReport();"> 
      Go to other report format</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td width="17%" height="24">View/Print Type</td>
      <td height="24"><select name="SummaryDetail">
          <option value=0>Summary</option>
          <%if (WI.fillTextValue("SummaryDetail").equals("1")) { %>
          <option value="1" selected>Detail</option>
          <% }else{%>
          <option value="1">Detail</option>
          <%}%>
        </select></td>
      <td>Date
        <select name="DateDefaultSpecify" onChange='ReloadPage();'>
          <option value="0" >Default cut-off date</option>
          <% if (WI.fillTextValue("DateDefaultSpecify").equals("1")){ %>
          <option value="1" selected>Specify date</option>
          <%}else{%>
          <option value="1">Specify date</option>
          <%}%>
        </select> </td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td height="25">Enter Employee ID </td>
      <td height="25"><input name="emp_id" id="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF';" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"> <label id="coa_info"></label></td>
      <td width="49%"> <% if (WI.fillTextValue("DateDefaultSpecify").equals("1")) {%>
        From
     <input name="from_date" type="text" size="10" maxlength="10"
	  value="<%=WI.fillTextValue("from_date")%>" class="textbox"
	  onKeyUp="AllowOnlyIntegerExtn('dtr_op','from_date','/');"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','from_date','/')">
        <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        &nbsp;&nbsp;to&nbsp;&nbsp;
        <input name="to_date" type="text" size="10" maxlength="10"
		value="<%=WI.fillTextValue("to_date")%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'"
		onKeyUP = "AllowOnlyIntegerExtn('dtr_op','to_date','/')"
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','to_date','/')">
        <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        <%}else{%> &nbsp; <%}%> </td>
    </tr>
<% if(WI.fillTextValue("print_by").compareTo("1") != 0){ %>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><table width="100%" border="0" cellspacing="0" cellpadding="0">
			<%if(strSchCode.startsWith("AUF")){%>
          <tr bgcolor="#FFFFFF">
            <td height="25">Employment Category </td>
            <td height="25">
						<select name="emp_type_catg" onChange="ReloadPage();">
							<option value="">ALL</option>
							<%
							strTemp = WI.fillTextValue("emp_type_catg");
							for(int i = 0;i < astrCategory.length;i++){
								if(strTemp.equals(Integer.toString(i))) {%>		
              <option value="<%=i%>" selected><%=astrCategory[i]%></option>
              <%}else{%>
              <option value="<%=i%>"> <%=astrCategory[i]%></option>
              <%}
							}%>							
            </select></td>
          </tr>
					<%}%>
          <tr bgcolor="#FFFFFF">
            <td width="18%" height="25">Employment Type</td>
            <td width="82%" height="25">
              <%strTemp2 = WI.fillTextValue("emp_type");%>
              <select name="emp_type">
                <option value="">ALL</option>
                <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 " +
								WI.getStrValue(WI.fillTextValue("emp_type_catg"), " and emp_type_catg = " ,"","") +
								"order by EMP_TYPE_NAME asc", strTemp2, false)%>
              </select>							</td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="25"><%if(bolIsSchool){%>
            College
              <%}else{%>
              Division
              <%}%></td>
            <td height="25"><select name="c_index" onChange="ReloadPage();">
                <option value="">N/A</option>
                <%
	strTemp = WI.fillTextValue("c_index");
	if (strTemp.length()<1) strTemp="0";
   if(strTemp.compareTo("0") ==0)
	   strTemp2 = "Offices";
   else
	   strTemp2 = "Department";%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="25"><%=strTemp2%></td>
            <td height="25"> <select name="d_index">
                <% if(strTemp.compareTo("") ==0){//only if from non college.%>
                <option value="">All</option>
                <%}else{%>
                <option value="">All</option>
                <%} strTemp3= WI.fillTextValue("d_index");%>
                <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp3, false)%> </select> </td>
          </tr>
          <tr bgcolor="#FFFFFF">
      		<td height="25">Office/Dept filter </td>
      		<td height="25"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters) </td>
          </tr>
					<%if(bolHasTeam){%>
          <tr bgcolor="#FFFFFF">
            <td height="25">Team</td>
            <td height="25"><select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select></td>
          </tr>
          <%}%>
        </table></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_all");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td colspan="3" height="25"><input type="checkbox" name="show_all" value="1" <%=strTemp%>>
      show all in single page </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				if(WI.fillTextValue("exclude_ghosts").length() > 0)
					strTemp = " checked";
				else
					strTemp = "";			
			%>
      <td colspan="3" height="25"><input type="checkbox" name="exclude_ghosts" value="1" <%=strTemp%>>show only with dtr</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				if(WI.fillTextValue("only_late_ut").length() > 0)
					strTemp = " checked";
				else
					strTemp = "";			
			%>			
      <td colspan="3" height="25"><input type="checkbox" name="only_late_ut" value="1" <%=strTemp%>>
      show only Tardiness and undertime </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" height="25">Print DTR whose lastname starts with
        <select name="lname_from" onChange="ReloadPage()">
<%
 strTemp = WI.fillTextValue("lname_from");
 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
 for(int i=0; i<28; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
 j = i;%>
          <option selected><%=strConvertAlphabet[i]%></option>
<%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
<%}
}%>
        </select>
        to
        <select name="lname_to">
          <option value="0"></option>
          <%
			 strTemp = WI.fillTextValue("lname_to");

			 for(int i=++j; i<28; ++i){
			 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select> </td>
    </tr>
    <%}//end of print by.
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><br> <input name="proceed" type="image" onClick="ViewRecords();" src="../../../images/form_proceed.gif">      </td>
    </tr>
 </table>
<%} if (WI.fillTextValue("viewRecords").equals("1")){

	if (vRetResult!=null) {
		iSearchResult = RE.getSearchCount();
		int iPageCount =  1;

		if (RE.defSearchSize != 0) {
			iPageCount = iSearchResult/RE.defSearchSize;
			if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
		}

	if(iPageCount > 1) {//show this if page cournt > 1%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
	 <tr>

      <td width="66%"><b>Total Result: <%=iSearchResult%>
<% 	strTemp = "checked";
	if (!WI.fillTextValue("show_all").equals("1")) {
	strTemp = "";
%>
	   - Showing(<%=RE.getDisplayRange()%>)
<%}%>
	   </b> &nbsp;&nbsp;&nbsp;
<% if (WI.fillTextValue("SummaryDetail").equals("0")){%>
       <input type="checkbox" name="show_all" value="1" <%=strTemp%>>
       click to show all
<%}%>	   </td>
		  <td width="26%">&nbsp;
<% if (!WI.fillTextValue("show_all").equals("1")) {%>

		  Jump To page:
		<select name="jumpto" onChange="goToNextSearchPage()">
 <%
	strTemp = request.getParameter("jumpto");
	if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
	for( int i =1; i<= iPageCount; ++i ){
	if(i == Integer.parseInt(strTemp) ){%>
		<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
    <%}else{%>
	   <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
    <%}
	} // end for loop
%>
	   </select>

<%}%>	   </td>
	  <td width="8%"><input name="image" type="image" src="../../../images/print.gif" align="right" onClick="PrintPage();"></td>
	</tr>
  </table>
 <%}//show jump page if page count > 1

 } // if ( PrintPage is not called.)
 
// System.out.println("SummaryDetail " + WI.fillTextValue("SummaryDetail"));
 if (WI.fillTextValue("SummaryDetail").equals("0")){ 	
  vSummaryWrkHours = RE.computeWorkingHourSummary(dbOP,request, WI.fillTextValue("emp_id"));
 	Vector vReqWrkHours = RE.computeRequiredHourSummary(dbOP, request, WI.fillTextValue("emp_id"));
//	System.out.println("vSummaryWrkHours " + vSummaryWrkHours);
//	System.out.println("vReqWrkHours " + vReqWrkHours);
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="8" align="center" bgcolor="#B9B292"><strong><font color="#FFFFFF">DTR
          SUMMARY (From <%=strDateFr%> to <%=strDateTo%>)</font></strong></td>
    </tr>
<%
	if (vRetResult!=null) {
%>
    <tr >
      <td width="4%" align="center" class="thinborder">&nbsp;</td>
      <td width="12%" height="25" align="center" class="thinborder"><strong>ID NUMBER</strong></td>
      <td width="23%" height="25" align="center" class="thinborder"><strong>NAME</strong></td>
      <td width="20%" height="25" align="center" class="thinborder"><strong><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%>/OFFICE</strong></td>
      <td width="16%" align="center" class="thinborder"><strong>POSITION</strong></td>
      <td width="9%" height="25" align="center" class="thinborder"><strong>REQ
        HRS</strong></td>
      <td width="9%" align="center" class="thinborder"><strong>&nbsp;HRS WORK </strong></td>
      <td width="7%" height="25" align="center" class="thinborder"><strong>DETAILS</strong></td>
    </tr>
 <%
 	int iIndexOf = -1;
	iIncr = 1;
	for (int i=0; i < vRetResult.size() ; i+=13,iIncr++){
		strTemp = (String)vRetResult.elementAt(i+3);

		if(strTemp == null)
			strTemp = (String)vRetResult.elementAt(i+4);
		else if(vRetResult.elementAt(i+4) != null)
			strTemp += "/"+(String)vRetResult.elementAt(i+4);

	strTemp2 = "";
	if (vSummaryWrkHours != null && vSummaryWrkHours.size() > 0){
		iIndexOf  = vSummaryWrkHours.indexOf((String)vRetResult.elementAt(i));

		if (iIndexOf != -1){
			vSummaryWrkHours.removeElementAt(iIndexOf);
			strTemp2 = CommonUtil.formatFloat(((Double)vSummaryWrkHours.remove(iIndexOf)).doubleValue(), true);
		}
	}

// updated October 8, 2007
//		strTemp2 = CommonUtil.formatFloat(eDTRUtil.longHourToFloat(RE.computeWorkingHourSummary(dbOP,request,
//					                               (String)vRetResult.elementAt(i))),true);
%>
  <tr >
    <td align="right" class="thinborder"><%=iIncr%>&nbsp;</td>
  <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
  <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%>, <%=(String)vRetResult.elementAt(i+1)%> </td>
  <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
  <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
<%
	strTemp = "";
	if (vReqWrkHours != null && vReqWrkHours.size() > 0){
		iIndexOf  = vReqWrkHours.indexOf((String)vRetResult.elementAt(i));

		if (iIndexOf != -1){
			vReqWrkHours.removeElementAt(iIndexOf);
			strTemp = (String)vReqWrkHours.remove(iIndexOf);
		}
	}
%>
  <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp,"0.00")%></td>
  <td class="thinborder"><strong>&nbsp;&nbsp;<%=WI.getStrValue(strTemp2,"0.00")%></strong></td>
  <td height="25" align="center" class="thinborder">
  <a href="javascript:ViewDTR('<%=(String)vRetResult.elementAt(i)%>',
	'<%=strDateFr%>','<%=strDateTo%>')"><img src="../../../images/view.gif" border="0"></a>  </td>
  </tr>
<% } // end for i < vRetResutl.size()
 } // if (vRetResult!=null)
else{ %>
    <tr>
      <td colspan="8" class="thinborder" > <strong><%=WI.getStrValue(RE.getErrMsg(),"")%></strong> <br>
        <strong> 0 RECORD FOUND</strong></td>
    </tr>
<%} // end error/no result%>
</table>
<% }
	else
   {  //end of display in  summary, begin of display in details

//	long lStartTime = new java.util.Date().getTime();
 %>

  <table width="100%" border="0" cellpadding="2" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr >
      <td height="25" colspan="<%=iColCount%>" align="center" bgcolor="#B9B292" class="thinborder"><strong><font color="#FFFFFF">DTR
        DETAILS (From <%=strDateFr%> to <%=strDateTo%>)</font></strong></td>
    </tr>
	</table>
<%if (vRetResult!=null && vRetResult.size() > 0) {%>
<table width="100%" border="0" cellpadding="2" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">	
<%
//	long lSubTotalWorkingHr = 0l;//sub total total working hour of employee.
	long lGTWorkingHr = 0l;//Total working hour of the employee for the specified date.
	long lOTHours = 0l; // Total OT hour for the day


	double dOTTotal = 0l; // Total OT Hours for the specified date

	double dTotalHoursWork = 0d;
	double dLateAM = 0d;
	double dLatePM = 0d;
	double dUTAM = 0d;
	double dUTPM= 0d;
	
	
//as requestd, i have to show all the days worked and non worked.
  for (int i=0; i<vRetResult.size() ; i+=13){

	  strTemp = (String)vRetResult.elementAt(i+3);

	if(strTemp == null)
		strTemp = (String)vRetResult.elementAt(i+4);
	else if(vRetResult.elementAt(i+4) != null)
		strTemp += "/"+(String)vRetResult.elementAt(i+4);

	vDayIntervalTemp = vDayIntervalTemp;
	
%>
    <tr >
      <td height="25" colspan="<%=iColCount%>" class="thinborder"> <%=(String)vRetResult.elementAt(i)%><font color="#0000FF"> :: &nbsp;</font> <font color="#FF0000"><%=(String)vRetResult.elementAt(i+2)%>, <%=(String)vRetResult.elementAt(i+1)%> </font> <font color="#0000FF"> :: &nbsp;</font> <%=WI.getStrValue(strTemp,"","::","")%><font color="#0000FF">&nbsp;  </font> <%=(String)vRetResult.elementAt(i+5)%><br>
        <%=WI.getStrValue((String)vRetResult.elementAt(i+7), "Date Hired : ","","")%> <%=WI.getStrValue((String)vRetResult.elementAt(i+8), " -- ","","")%></td>
    </tr>
    <tr >
      <td width="12%" height="25" align="center" class="thinborder"><strong><font size="1">DATE</font></strong></td>
			<%if(!bolOnlyLateUT){%>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">TIME-IN</font></strong></td>
			<%}%>
      <td width="5%" align="center" class="thinborder"><strong>LATE</strong></td>
			<%if(!bolOnlyLateUT){%>			
      <td width="12%" align="center" class="thinborder"><strong><font size="1">TIME-OUT</font></strong></td>
			<%}%>
      <td width="3%" align="center" class="thinborder"><strong>UT</strong></td>
			<%if(!bolOnlyLateUT){%>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">TIME-IN</font></strong></td>
			<%}%>
      <td width="5%" align="center" class="thinborder"><strong>LATE</strong></td>
			<%if(!bolOnlyLateUT){%>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">TIME-OUT</font></strong></td>
			<%}%>
      <td width="5%" align="center" class="thinborder"><strong>UT</strong></td>
			<%if(!bolOnlyLateUT){%>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">NO. OF HOURS</font></strong></td>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">OVERTIME</font></strong></td>
			<%}%>
		</tr>
    <%

//long lCurrentTime =  new java.util.Date().getTime();

vRetEDTR = RE.getDTRDetails(dbOP,(String)vRetResult.elementAt(i), true, true);
vHoursWork = RE.computeWorkingHour(dbOP, (String)vRetResult.elementAt(i),
											strDateFr, strDateTo, null, null);
//System.out.println("vHoursWork " + vHoursWork);											
vHoursOT  =  RE.getOTHours(dbOP, (String)vRetResult.elementAt(i),
											strDateFr, strDateTo, null, null);
//System.out.println("vHoursOT " + vHoursOT);
//System.out.println("i -------" + (String)vRetResult.elementAt(i));
vAWOLRecords = RE.getAWOLEmployee(dbOP, (String)vRetResult.elementAt(i+6), strDateFr, strDateTo, strSchCode);
//System.out.println("vAWOLRecords " + vAWOLRecords);

if (vRetEDTR == null || vRetEDTR.size() ==  0) {
	strErrMsg=RE.getErrMsg();
}else{
	if (vRetEDTR.size() == 1){//non DTR employees
%>
    <tr>
      <td height="20" colspan="<%=iColCount%>" align="center" class="thinborder"><%=vRetEDTR.elementAt(0)%></td>
    </tr>

<%}else{
		strTemp3 = "";

		String strPrevDate = "";//this is added to avoid displaying date in 2nd row.
		boolean bolDateRepeated = false;

	String strLatePMEntry = null;
	String strUTPMEntry = null;
	
	String strCheckPMEntry = null;

	int iIndexOf = 0;
	String strHrsWork = null;

	double dTemp = 0d;
	double dHoursWork = 0d;
	double dUnworkHours = 0d;
	double dUnworkMins = 0d;
	double dUnworkMinsRow = 0d;
	long lCurrenTime  = new java.util.Date().getTime();
	// check the number of elements in the ReportEDTR.java file
	int iElementCount = 15;
	if(vLateTimeIn != null){
		iAllowedLateAm = Integer.parseInt((String)vLateTimeIn.elementAt(1));
		iAllowedLatePm = Integer.parseInt((String)vLateTimeIn.elementAt(2));
	}
	
//	System.out.println("iAllowedLateAm " + iAllowedLateAm);
//	System.out.println("iAllowedLatePm " + iAllowedLatePm);
	
	for(iIndex=0;iIndex<vRetEDTR.size();iIndex +=iElementCount){
		
		dUnworkHours = 0d;
		dUnworkMins = 0d;
		dUnworkMinsRow = 0d;
 		strHrsWork = null;
		strTemp =(String)vRetEDTR.elementAt(iIndex+4);

		if (strTemp!=null &&  (iIndex+iElementCount) < vRetEDTR.size() &&
			strTemp.equals((String)vRetEDTR.elementAt(iIndex+iElementCount+4))){
			strTemp = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + iElementCount + 2)).longValue(),iDateFormat);
			strTemp2 = WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + iElementCount + 3)).longValue(),iDateFormat);
			strLatePMEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+6+iElementCount));
			strUTPMEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+7+iElementCount));
			strCheckPMEntry = WI.getStrValue((String)vRetEDTR.elementAt(iIndex+8+iElementCount));
		}
		else {
			strTemp =  null;
			strTemp2 = null;
			strLatePMEntry = "";
			strUTPMEntry = "";
			strCheckPMEntry = "";
		}
		if(strPrevDate.equals((String)vRetEDTR.elementAt(iIndex+4))) {
			bolDateRepeated = true;
		}
		else {
			bolDateRepeated = false;
			strPrevDate = (String)vRetEDTR.elementAt(iIndex+4);
		}


//I ahve to display here for the days employee did not work.
if(!bolDateRepeated && vDayInterval != null && vDayInterval.size() > 0) {
	while(!strPrevDate.equals((String)vDayInterval.elementAt(0))) {
	%>
  <tr>
    <td height="20" class="thinborder" colspan="<%=iColCount%>" align="center" bgcolor="#CCDDDD">
	<%=(String)vDayInterval.remove(0)+":::"+(String)vDayInterval.remove(0)%></td>
  </tr>
  <%}//end of while looop
  if(vDayInterval.size() > 0)  {
  	vDayInterval.removeElementAt(0);vDayInterval.removeElementAt(0);
  }

}//end of if condition to print holidays.%>
    <tr>
      <td height="20" class="thinborder">
	    <%if(!bolDateRepeated){%>
        <%=(String)vRetEDTR.elementAt(iIndex+4)%>
        <%}else{%>
				&nbsp;
        <%}%>			</td>
			<%if(!bolOnlyLateUT){%>
      <td class="thinborder"><%=WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 2)).longValue(),iDateFormat)%><%=WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 8))%></td>
			<%}%>
			<%
				strMinUnwork = WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 6), "0");
				dUnworkMins = Double.parseDouble(strMinUnwork);
				dLateAM += dUnworkMins;
				if(dUnworkMins >= iAllowedLateAm){
					dUnworkMinsRow += dUnworkMins;
				}
				if(dUnworkMins == 0d)
					strMinUnwork = "&nbsp;";
			%>
      <td align="right" class="thinborder"><%=strMinUnwork%>&nbsp;</td>
			<%if(!bolOnlyLateUT){%>
      <td class="thinborder"><%=WI.getStrValue(WI.formatDateTime(((Long)vRetEDTR.elementAt(iIndex + 3)).longValue(),iDateFormat),
	  								"&nbsp;")%></td>
			<%}%>
			<%
				strMinUnwork = WI.getStrValue((String)vRetEDTR.elementAt(iIndex + 7), "0");
				dUnworkMins = Double.parseDouble(strMinUnwork);
				dUnworkMinsRow += dUnworkMins;
				dUTAM += dUnworkMins;
				if(dUnworkMins == 0d)
					strMinUnwork = "&nbsp;";
				
			%>
      <td align="right" class="thinborder"><%=WI.getStrValue(strMinUnwork)%>&nbsp;</td>
			<%if(!bolOnlyLateUT){%>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%><%=WI.getStrValue(strCheckPMEntry, "&nbsp;")%></td>
			<%}%>
			<%
				strMinUnwork = WI.getStrValue(strLatePMEntry, "0");
				dUnworkMins = Double.parseDouble(strMinUnwork);				
				dLatePM += dUnworkMins;
				if(dUnworkMins >= iAllowedLatePm)
					dUnworkMinsRow += dUnworkMins;			
				if(dUnworkMins == 0d)
					strLatePMEntry = "&nbsp;";						
			%>
      <td align="right" class="thinborder"><%=strLatePMEntry%>&nbsp;</td>
			<%if(!bolOnlyLateUT){%>
      <td class="thinborder"><%=WI.getStrValue(strTemp2,"&nbsp;")%></td>
			<%}%>
			<%
				strMinUnwork = WI.getStrValue(strUTPMEntry, "0");
				dUnworkMins = Double.parseDouble(strMinUnwork);
				dUnworkMinsRow += dUnworkMins;
				dUTPM += dUnworkMins;
				if(dUnworkMins == 0d)
					strUTPMEntry = "&nbsp;";					
			%>
      <td align="right" class="thinborder"><%=strUTPMEntry%>&nbsp;</td>
      <%  // compute for the working hour for the day

//		System.out.println("heellow world");

		if(strTemp2 != null) iIndex += iElementCount;


//	 ---- Updated to Vector..
//		lSubTotalWorkingHr = RE.computeWorkingHour(dbOP, (String)vRetResult.elementAt(i),
//								(String)vRetEDTR.elementAt(iIndex+4));


//		System.out.println("lSubTotalWorkingHr : " + lSubTotalWorkingHr);

//		lOTHours = RE.getOTHours(dbOP,(String)vRetResult.elementAt(i),
//								(String)vRetEDTR.elementAt(iIndex+4));

//		if (lSubTotalWorkingHr < 0) lSubTotalWorkingHr = 0l;
//		if (lOTHours < 0) lOTHours = 0l;

//		if (!strTemp3.equals((String)vRetEDTR.elementAt(iIndex+4))){
//				strTemp3  = (String)vRetEDTR.elementAt(iIndex+4);
//				lGTWorkingHr += lSubTotalWorkingHr;
//				lOTTotal +=lOTHours;
//		}else{
//			lSubTotalWorkingHr = 0l;
//		}

		if (vHoursWork != null && vHoursWork.size() > 0){

			iIndexOf = vHoursWork.indexOf((String)vRetEDTR.elementAt(iIndex+4));
			if (iIndexOf != -1) {
				vHoursWork.removeElementAt(iIndexOf-1);
				vHoursWork.removeElementAt(iIndexOf-1);
				dHoursWork =((Double)vHoursWork.remove(iIndexOf-1)).doubleValue();
				//System.out.println("dHoursWork -----------" + dHoursWork);
				strHrsWork = CommonUtil.formatFloat(dHoursWork,true);
				dTotalHoursWork += dHoursWork;				 
			}
		}
 	%>
	
	<%if(!bolOnlyLateUT){%>
      <td class="thinborder">&nbsp;
        <%if(iIndexOf != -1){%>
        <%=WI.getStrValue(strHrsWork)%>
      <%}%></td>

	<%iIndexOf = -1;
		dHoursWork = 0d;
		if (vHoursOT != null && vHoursOT.size() > 0){			
			iIndexOf = vHoursOT.indexOf((String)vRetEDTR.elementAt(iIndex+4));
			while (iIndexOf != -1) {
				vHoursOT.removeElementAt(iIndexOf-1);
				vHoursOT.removeElementAt(iIndexOf-1);
				dTemp = ((Double)vHoursOT.remove(iIndexOf-1)).doubleValue();
				dHoursWork += dTemp;
				strHrsWork = CommonUtil.formatFloat(dHoursWork,true);
				dOTTotal += dTemp;				
				iIndexOf = vHoursOT.indexOf((String)vRetEDTR.elementAt(iIndex+4));
			}
		} 
 		%>

      <td align="right" class="thinborder"><%=(dHoursWork > 0d)?strHrsWork:""%>&nbsp;</td>
			<%}%>
    </tr>
    <%
	  } // end for loop
//	  System.out.println("Time : " + (lCurrenTime - new java.util.Date().getTime()));

	  //I have to now print if there are any days having zero working hours.
	while(vDayInterval != null && vDayInterval.size() > 0) {
	%>
  <tr>
    <td height="20" class="thinborder" colspan="<%=iColCount%>" align="center" bgcolor="#CCDDDD">
	  <%=(String)vDayInterval.remove(0)+":::"+(String)vDayInterval.remove(0)%></td>
  </tr>
  <%}//end of while looop


	 }
	}
	%>
    <%if(!bolOnlyLateUT){%>
		<tr >
      <td height="20" colspan="8" align="right" class="thinborder"><strong>TOTAL
        HOURS WORKED</strong>&nbsp;&nbsp;&nbsp;</td>
      <td align="center" class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder"> <%=CommonUtil.formatFloat(dTotalHoursWork,true)%></td>
      <td align="right" class="thinborder"> <%=CommonUtil.formatFloat(dOTTotal,true)%>&nbsp;</td>
		</tr>
		<%}else{%>
		<tr >
      <td height="20" align="right" class="thinborder"> <strong>TOTAL&nbsp;</strong></td>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dLateAM,false)%>&nbsp;</td>
      <td align="right" class="thinborder"> <%=CommonUtil.formatFloat(dUTAM,false)%>&nbsp;</td>
      <td align="right" class="thinborder"> <%=CommonUtil.formatFloat(dLatePM,false)%>&nbsp;</td>
			<td align="right" class="thinborder"> <%=CommonUtil.formatFloat(dUTPM,false)%>&nbsp;</td>
		</tr>
		
		<%}%>
    <%
		dLateAM = 0d;
		dLatePM = 0d;
		dUTAM = 0d;
		dUTPM = 0d;
		
	dTotalHoursWork = 0d;
	dOTTotal = 0d;
	}	 
	%>
  </table>
	<%}else{%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">	
    <tr >
      <td height="25" colspan="11"><strong><%=WI.getStrValue(strErrMsg)%></strong> <br> <br> <strong>O RECORD FOUND</strong></td>
    </tr>
  </table>
	<%} // end if (vRetEDTR.size() == 1)%>
<% }// end if(vRetEDTR == null || vRetEDTR.size() ==  0)%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="print_table">
    <tr >
      <td height="25" colspan="6" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
	<tr >
      <td height="25" colspan="6" bgcolor="#FFFFFF" align="center">
	  	<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
	  </td>
    </tr>
</table>
<%}//%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="footer_">
    <tr bgcolor="#ffffff">
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25">&nbsp;</td>
    </tr>
</table>

<input type=hidden name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>">
<input type=hidden name="viewRecords" value="0">
<input type=hidden name="print_page">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
