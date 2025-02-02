<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR,eDTR.TimeInTimeOut"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Summary of EDTR Adjustments</title>
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
<script language="Javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function goToNextSearchPage(){
	ViewRecords();
}	
function ReloadPage()
{
	document.dtr_op.print_page.value="";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value ="0";
	document.dtr_op.submit();
}

function ViewRecordDetail(index){
	document.dtr_op.print_page.value="";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.SummaryDetail.value="1";
	document.dtr_op.emp_id.value=index;
	document.dtr_op.emp_type.value ="";
	document.dtr_op.c_index.value ="";
	document.dtr_op.d_index.value ="";
	document.dtr_op.submit();
}
function ViewRecords()
{
	document.dtr_op.print_page.value="";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.submit();
}
function CallPrint()
{
	document.dtr_op.print_page.value="1";
	document.dtr_op.submit();
}

function DeleteRecord(strInfo){

	document.dtr_op.print_page.value="";
	document.dtr_op.info_index.value=strInfo;
	document.dtr_op.page_action.value="1";
	document.dtr_op.submit();
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
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").compareTo("1") ==0)
{ %>
	<jsp:forward page="./emp_edtr_adjustments_print.jsp" />
<%}
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	int iSearchResult =0;
	int iPageCount = 0;
	boolean bolHasTeam = false;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Report-Employees with Adjustments",
								"emp_dtr_adjustments.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
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

ReportEDTR RE = new ReportEDTR(request);
TimeInTimeOut tRec = new TimeInTimeOut();
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};
strTemp = WI.fillTextValue("info_index");

int iAction = Integer.parseInt(WI.getStrValue(strTemp,"0"));

if (iAction == 1){	
	if(!tRec.operateOnAdjustments(dbOP,request,iAction))
		strErrMsg = tRec.getErrMsg();
	else
		strErrMsg = "Adjustment record deleted successfully";
}

if (WI.fillTextValue("viewRecords").equals("1")) {
	vRetResult = RE.searchEDTRAdjustments(dbOP);
	if (vRetResult == null || vRetResult.size() == 0) {	
		strErrMsg = RE.getErrMsg();
	}else{
		iSearchResult = RE.getSearchCount();	
	}
}
%>
<form action="./emp_edtr_adjustments.jsp" name="dtr_op" method="post">
<table width="100%" border="0" cellspacing="0" cellpadding="3">
  <tr bgcolor="#FFFFFF">
    <td height="25" colspan="3" align="center" bgcolor="#A49A6A" class="footerDynamic"><strong><font color="#FFFFFF">SUMMARY OF EDTR ADJUSTMENTS</font></strong> </td>
    </tr>
  <tr bgcolor="#FFFFFF">
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2"><font color="#FF0000" size="3"><strong>&nbsp;
        <%=WI.getStrValue(strErrMsg)%></strong></font></td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2"><strong>Date</strong> &nbsp;&nbsp;&nbsp;&nbsp;::
      &nbsp;From:
      <input name="from_date" type="text" size="12"  
  	 onFocus="style.backgroundColor='#D3EBFF'" class="textbox"
	 onKeyUP ="AllowOnlyIntegerExtn('dtr_op','from_date','/')"
	 onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','from_date','/')" 
	 value="<%=WI.fillTextValue("from_date")%>"> 
      <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;To 
      : 
      <input name="to_date"  onFocus="style.backgroundColor='#D3EBFF'"  class="textbox"  
		onKeyUP ="AllowOnlyIntegerExtn('dtr_op','to_date','/')" type="text" size="12" 
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','to_date','/')"  
		value="<%=WI.fillTextValue("to_date")%>"> 
      <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;</td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td width="2%" height="25">&nbsp;</td>
    <td width="21%" height="25">Enter Employee ID </td>
    <td height="25"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"> <label id="coa_info"></label></td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <%if(strSchCode.startsWith("AUF")){%>
				<tr bgcolor="#FFFFFF">
          <td height="25">Employment Category </td>
					<%
						strTemp = WI.fillTextValue("emp_type_catg");
					%>
          <td height="25"><select name="emp_type_catg" onChange="ReloadPage();">
            <option value="">ALL</option>
            <%
							for(int i = 0;i < astrCategory.length;i++){
								if(strTemp.equals(Integer.toString(i))) {%>            		
							%>
            <option value="<%=i%>" selected><%=astrCategory[i]%></option>
            <%}else{%>
            <option value="<%=i%>"> <%=astrCategory[i]%></option>
            <%}
							}%>
          </select></td>
        </tr>
				<%}%>
        <tr bgcolor="#FFFFFF"> 
          <td width="20%" height="25">Employment Type</td>
          <td width="80%" height="25"><strong> 
            <select name="emp_type">
              <option value="">ALL</option>
              <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 " +
							WI.getStrValue(WI.fillTextValue("emp_type_catg"), " and emp_type_catg = " ,"","") +
							" order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type"), false)%> 
            </select>
            </strong></td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
          <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> </td>
          <td height="25"><select name="c_index" onChange="ReloadPage();">
              <option value="">N/A</option>
              <%
	strTemp = WI.fillTextValue("c_index");
	if (strTemp.length() == 0) 
			strTemp="0";
   if(strTemp.equals("0"))
	   strTemp2 = "Offices";
   else
	   strTemp2 = "Department";
%>
              <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select> </td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
          <td height="25"><%=strTemp2%></td>
          <td height="25"> <select name="d_index">
              <option value="">All</option>
              <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+			
			  			strTemp+" order by d_name asc",WI.fillTextValue("d_index"), false)%> 
			  </select>		  </td>
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
          <td>
					<select name="team_index">
						<option value="">All</option>
						<%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
															" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
					</select>
    	  	</td>
        </tr>
				<%}%>
      </table></td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td height="25">&nbsp;</td>
    <td height="25" colspan="2"><input name="proceed" type="image" onClick="ViewRecords();" src="../../../images/form_proceed.gif">    </td>
  </tr>
</table>

<table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="13">       </td>
  </tr>
<% if (vRetResult!= null && vRetResult.size() > 0) { %>
  <tr> 
      <td> 
          <%  
		  if (RE.defSearchSize > 0) { 
			iPageCount = iSearchResult/RE.defSearchSize;
			if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
		  }
 		 %>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td>
			<% 	if (WI.fillTextValue("show_all").equals("1")) 
					strTemp = "checked";
				else
					strTemp = "";
			%>
			<input type="checkbox" name="show_all" value="1" <%=strTemp%>>
              <font size="1">check to show all</font> </td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td width="56%"><b>Total Requests: <%=iSearchResult%> 
			<% if (!WI.fillTextValue("show_all").equals("1")) {%>
				- Showing(<%=RE.getDisplayRange()%>)
			<%}%> 
			
			</b></td>
            <td width="27%">
			<% if (!WI.fillTextValue("show_all").equals("1")) {%>
			Jump To page: 
              <select name="jumpto" onChange="goToNextSearchPage();">
                <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
                <option value="<%=i%>" selected><%=i%> of <%=iPageCount%></option>
                <%}else{%>
                <option value="<%=i%>" ><%=i%> of <%=iPageCount%></option>
                <%
					}
			}
			%>
            </select>
			<%}%> &nbsp;
			</td>
            <td width="17%">
				<a href="javascript:CallPrint()"> <img src="../../../images/print.gif" border="0"></a>
			<font size="1"> print list</font></td>
          </tr>
        </table>
        <br> 
      <table width="100%" border="0" cellpadding="1" cellspacing="0" class="thinborder">
          <tr bgcolor="#006A6A"> 
		  	<% strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); %>
            <td height="25"  colspan="9" align="center" bgcolor="#F8EFF7" class="thinborder"><strong>LIST 
            OF EMPLOYEE DTR ADJUSTMENTS (<%=strTemp%>)</strong></td>
          </tr>
          <tr> 
            <td width="24%" height="25" bgcolor="#EBEBEB" class="thinborder"><strong><font size="1">EMPLOYEE</font></strong></td>
            <td width="8%" height="25" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>STATUS</strong></font></td>
            <td width="10%" height="25" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>ACTUAL DATE </strong></font></td>
            <td width="12%" height="25" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>ACTUAL TIME </strong></font></td>
            <td width="12%" height="25" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>ADJUSTED<br> 
            DATE</strong></font></td>
            <td width="12%" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>ADJUSTED <br>
            TIME</strong></font></td>
            <td width="10%" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>ADJ BY </strong></font></td>
            <td width="12%" height="25" bgcolor="#EBEBEB" class="thinborder"><font size="1"><strong>DATE </strong></font></td>
		<!-- no delete allowed heheheheh 
            <td width="9%" height="30" bgcolor="#EBEBEB" class="thinborder">&nbsp;</td>
		--> 
          </tr>
<% 
String strTempName = null;
String strEmpName = null;
String strCurrID = null;
long lTemp = 0l;
String strAdjBy = null;
 
for (int i = 0; i < vRetResult.size();  i+=22){
	if (strCurrID != null && strCurrID.equals((String)vRetResult.elementAt(i+1))){
		strEmpName = "";
	}else{
		strCurrID = (String)vRetResult.elementAt(i+1);
		strEmpName = WI.formatName((String)vRetResult.elementAt(i+2),
									(String)vRetResult.elementAt(i+3),
									(String)vRetResult.elementAt(i+4),4);
	}

		strAdjBy = "";
		if ((String)vRetResult.elementAt(i+15) != null)
			strAdjBy += (((String)vRetResult.elementAt(i+15)).substring(0, 1)).toLowerCase();
		if ((String)vRetResult.elementAt(i+16) != null)
			strAdjBy += (((String)vRetResult.elementAt(i+16)).substring(0, 1)).toLowerCase();
		strAdjBy += (String)vRetResult.elementAt(i+17);		
%>
	<%if(strEmpName.length() > 0){%>
   <tr>
     <td height="20" colspan="8" class="thinborder"><strong><%=strEmpName%></strong></td>
     </tr>
	 <%}%>
<%	
lTemp = ((Long)vRetResult.elementAt(i+5)).longValue();	
if (lTemp != 0){
	strTempName = "Time In"; // status
//	strTemp2 = ; //  old date 
//	strTemp4 = ;  // adjusted date


	if (((Long)vRetResult.elementAt(i+9)).longValue() != 0 )
	 	strTemp3 = WI.formatDateTime(((Long)vRetResult.elementAt(i+9)).longValue(),2);
	 else
	 	strTemp3 = "&nbsp;";
%>
   <tr> 
    <td height="20" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+18),"&nbsp;")%> </td> 
	  <td class="thinborder"><%=strTempName%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+11),"&nbsp;")%></td>            
    <td class="thinborder"><%=WI.getStrValue(strTemp3,"&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
    <td class="thinborder"><%=WI.formatDateTime(lTemp,2)%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue(strAdjBy,"&nbsp;")%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+14)%></td>
  </tr>	
  
<% 
	strEmpName = "";
} 

lTemp = ((Long)vRetResult.elementAt(i+6)).longValue();	

if (lTemp != 0){ 
	strTempName = "Time Out"; // status
//	strTemp3 = Long.toString(((Long)vRetResult.elementAt(i+10)).longValue()); //  old time out

	if (((Long)vRetResult.elementAt(i+10)).longValue() != 0 )
	 	strTemp3 = WI.formatDateTime(((Long)vRetResult.elementAt(i+10)).longValue(),2);
	 else
	 	strTemp3 = "&nbsp;";
%>
   <tr> 
    <td height="20" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+18),"&nbsp;")%> </td> 
	  <td class="thinborder"><%=strTempName%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+12),"&nbsp;")%></td>            
    <td class="thinborder"><%=WI.getStrValue(strTemp3,"&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%></td>
    <td class="thinborder"><%=WI.formatDateTime(lTemp,2)%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue(strAdjBy,"&nbsp;")%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+14)%></td>
  </tr>	
<% } // check if time out is needed.. 
} // end for loop
%>
	    </table>
	</td>
  </tr>
<%}%>
</table>   
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>     
<input type="hidden" name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>"> 
<input type="hidden" name="page_action">
<input type="hidden" name="viewRecords" value="0"> 
<input type="hidden" name="info_index">
<input type="hidden" name="print_page" value="">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>