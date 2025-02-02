<%@ page language="java" import="utility.*,java.util.Vector,eDTR.FacultyDTR" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(7);	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript"> 
function ReloadPage()
{
	document.form_.searchEmployee.value="";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
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
		this.setEIP(false);
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}

</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strPrepareToEdit = null;

//add security here.
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./schedule_by_subject_print.jsp" />
	<% 
return;}
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","schedule_by_subject.jsp");
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
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(), 
														"schedule_by_subject.jsp");	
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","PROCTOR",request.getRemoteAddr(), 
														null);	
}														
														
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
	FacultyDTR WHour = new FacultyDTR(); 
 	Vector vRetResult = null;
	Vector vEmployeeWH = null;
	String[] astrConvertWeekDay= {"SUNDAY","MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"};	
	String[] astrConverAMPM = {"AM","PM"};
	if(bolIsSchool)
		 strTemp = "College";
	else
		 strTemp = "Division";
	String[] astrSortByName    = {"Employee ID","Firstname","Lastname",strTemp,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname","c_name","d_name"};	
	int iSearchResult = 0;
	int i = 0;
	String strCurSubject = null;
	String strPrevSubject = "";
	boolean bolShowSubject = true;

		vRetResult = WHour.getProctorScheduleBySubject(dbOP, request);
		if(vRetResult == null){
			strErrMsg += WI.getStrValue(WHour.getErrMsg());
		}else
			iSearchResult = WHour.getSearchCount();
%>
<form action="schedule_by_subject.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      WORKING HOURS MGMT - PROCTOR SCHEDULE PAGE ::::</strong></font></td>
    </tr>
  </table>
	 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5">&nbsp;<a href="./proctor_main.jsp">
			<img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a>
			<font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>		
		
		<%if(bolIsSchool){%>		
		<tr>
		  <td width="2%" height="24">&nbsp;</td>
		  <td width="17%">Generate for &nbsp;Date</td>
			<%
					strTemp = WI.fillTextValue("date_from");
			%>				
		  <td width="81%" colspan="3"><input name="date_from" type="text" size="12" maxlength="12" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../../images/calendar_new.gif" border="0"></a> to
				<%
						strTemp = WI.fillTextValue("date_to");
				%>
			<input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../../images/calendar_new.gif" border="0"></a></td>
	  </tr>
		
		<%}%>
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
      <td height="10" colspan="3"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
        <strong><a href="javascript:OpenSearch();"></a></strong>
        <label id="coa_info"></label>			</td></tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
    <tr>
      <td height="10" colspan="5">OPTION</td>
    </tr>
    
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">
			<%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">        View ALL </td>
    </tr>		
  </table>	
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td width="3%" height="10">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
      <font size="1">click to display employee list to print</font></td>
    </tr>
  </table>	
	 <%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>   
      <% if (vRetResult != null && vRetResult.size() > 0 ){%>
      <td height="10"><div align="right"><font size="2">Number of Employees / rows Per 
        Page :</font><font>
                  <select name="num_rec_page">
                    <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
                    <option selected value="<%=i%>"><%=i%></option>
                    <%}else{%>
                    <option value="<%=i%>"><%=i%></option>
                    <%}}%>
                  </select>
                  <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div></td>
      <%}%>
    </tr>
    <%if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/WHour.defSearchSize;		
	if(iSearchResult % WHour.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr>
      <td><div align="right"><font size="2">Jump To page:
        <select name="jumpto" onChange="SearchEmployee();">
      <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
                  <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
                  <%}else{%>
                  <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
                  <%
					}
			}
			%>
          </select>
      </font></div></td>
    </tr>
    <%} // end if pages > 1
		}// end if not view all%>
  </table>	 
	 
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="6" align="center" bgcolor="#B9B292" class="thinborder"><strong>EXAM SCHEDULE </strong></td>
    </tr>
    <tr>
      <td width="5%" height="23" class="thinborder">&nbsp;</td>
      <td width="15%" class="thinborder">&nbsp;</td> 
      <td width="38%" align="center" class="thinborder"><strong><font size="1">TIME</font></strong></td>
			<td width="17%" align="center" class="thinborder"><strong><font size="1">ROOM</font></strong></td>
			<!--
      <td width="8%" align="center" class="thinborder">&nbsp;</td>
			-->
      <td width="25%" align="center" class="thinborder"><strong><font size="1">PROCTOR</font></strong></td>
    </tr>
    
    <% 	int iCount = 1;
	   for (i = 0; i < vRetResult.size(); i+=30,iCount++){
		 		strCurSubject = (String)vRetResult.elementAt(i);
		 		if(!strCurSubject.equals(strPrevSubject))
					bolShowSubject = true;		 	
		 %>
    <%if(bolShowSubject){
				bolShowSubject = false;
				//iCount = 1;
		%>
		<tr>
			<%
				strTemp = (String)vRetResult.elementAt(i+1) + " " + (String)vRetResult.elementAt(i+2);
			%>
      <td height="25" colspan="5" class="thinborder">&nbsp;<%=strTemp%></td>
    </tr>
		<%
			strPrevSubject = strCurSubject;
		}%>
    <tr>
      <td height="25" class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+24)%></td> 
      <input type="hidden" name="user_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
	 <%
			strTemp = (String)vRetResult.elementAt(i + 4);		
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+5),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" +astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+6))];
			
			// time to here
			strTemp += " - " + (String)vRetResult.elementAt(i + 7);
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+8),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" + astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+9))];
			
			strTemp = (String)vRetResult.elementAt(i+3) + " " + strTemp;
			%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+25)%></td>
      <!--
			<td align="center" class="thinborder"><strong><a href="javascript:ViewSchedule('<%=(String)vRetResult.elementAt(i+1)%>');"><img src="../../../../images/view.gif" width="40" height="31" border="0"></a></strong></td>
			-->
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+22)%></td>
    </tr>
    <%} //end for loop%>
    
    <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>	

	<%}// end if vRetResult != null%>
<!-- here lies the great mysteries of and future-->
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25"s>&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="searchEmployee" > 
	<input type="hidden" name="info_index">
  <input type="hidden" name="page_action">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
