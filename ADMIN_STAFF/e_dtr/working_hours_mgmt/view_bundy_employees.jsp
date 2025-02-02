<%@ page language="java" import="utility.*,java.util.Vector,eDTR.WorkingHour,eDTR.ReportEDTR" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.bgColor = "#FFFFFF";	
	document.getElementById("tr_print_header").style.display = "table-row"; //header
	document.getElementById("tr_result_header").bgColor = "#FFFFFF";	
		
	var oRows = document.getElementById('tbl_title').getElementsByTagName('tr');
	var iRowCount = oRows.length;
	while(iRowCount > 0) {
		document.getElementById('tbl_title').deleteRow(0);
		--iRowCount;
	}
	oRows = document.getElementById('tbl_filter').getElementsByTagName('tr');
	iRowCount = oRows.length;
	while(iRowCount > 0) {
		document.getElementById('tbl_filter').deleteRow(0);
		--iRowCount;
	}
	document.getElementById('tbl_print_btn').deleteRow(0);
	
	alert("Click OK to print this page");	
	window.print();
}
function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	document.form_.print_page.value="";
	//this.SubmitOnce("form_");
	document.form_.submit();
}

</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
 //add security here.
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./allowances_manual_print.jsp" />
	<% 
return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDTR-DTR Operations-Set working hour exception","set_whour_exception.jsp");		
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(),
														"set_whour_exception.jsp");
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

	Vector vRetResult = null;
	Vector vSalaryPeriod 		= null;//detail of salary period.
	WorkingHour whException = new WorkingHour();
	ReportEDTR RE = new ReportEDTR(request);
	int iSearchResult = 0;
	int i = 0;
	String streDTRPeriod  = null;
	String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
	if(bolIsSchool)
		 strTemp = "College";
	else
		 strTemp = "Division";	
	String[] astrSortByName    = {"Employee ID","Firstname",strTemp,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","c_name","d_name"};
	String strPageAction = WI.fillTextValue("page_action");	
	vRetResult = RE.getBundyWorkDetails(dbOP,WI.fillTextValue("date_fr"),WI.fillTextValue("date_to"));
	if(vRetResult == null)
			strErrMsg = RE.getErrMsg();
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="ToggleField();">
<form action="view_bundy_employees.jsp" method="post" name="form_">

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="tbl_title">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        eDTR :VIEW BUNDY CLOCK EMPLOYEES   ::::</strong></font></td>
    </tr>
</table> 

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="tbl_filter" >
	<tr>
      <td height="25" width="100">&nbsp;</td>
	 </tr>
	<tr>
      <td height="25">&nbsp;</td>
      <td width="10%">Date</td>
			<%
				strTemp = WI.fillTextValue("date_fr");
				if(strTemp.length() == 0 && request.getParameter("date_fr") == null)
					strTemp = WI.getTodaysDate(1);
			%>
      <td height="25" colspan="3"><input name="date_fr" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_fr','/');"  
				 onKeyUp="AllowOnlyIntegerExtn('form_','date_fr','/');"				
				size="10" value="<%=strTemp%>"  maxlength="10">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
				
        to 
			<%
				strTemp = WI.fillTextValue("date_to");
				if(strTemp.length() == 0 && request.getParameter("date_to") == null)
					strTemp = WI.getTodaysDate(1);
			%>
			<input name="date_to" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_to','/');"  
				 onKeyUp="AllowOnlyIntegerExtn('form_','date_to','/');"				
				size="10" value="<%=strTemp%>"  maxlength="10">
			<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
        <img src="../../../images/calendar_new.gif" width="20" height="16" border="0" id="date_to_"></a>
				</td>
    </tr>
	<tr>
		 <td height="25">&nbsp;</td>
		<td colspan="1">
			Hours rendered 
		</td>
		<td colspan="3">	
		<%	strTemp = WI.fillTextValue("rendered_hours_stat"); %>
			<select name="rendered_hours_stat">
				<option value="0" <%=strTemp.equals("0")?"selected":"" %> >Equals</option>
				<option value="1" <%=strTemp.equals("1")?"selected":"" %> >Greater than</option>
				<option value="2" <%=strTemp.equals("2")?"selected":"" %> >Less than</option>
			</select>
			<input type="text" name="number_of_hours"  value="<%=WI.fillTextValue("number_of_hours")%>" size="5" onKeyUp="AllowOnlyFloat('form_','number_of_hours');" onBlur="AllowOnlyFloat('form_','number_of_hours');" /> hrs.
		</td>	
	</tr>
	 <tr> 
      <td height="29">&nbsp;</td>
	 </tr> 
	 <!--
    <tr> 
      <td height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29" width="15%" ><select name="sort_by1">
        <option value="">N/A</option>
        <%=whException.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29" width="15%"><select name="sort_by2">
        <option value="">N/A</option>
        <%=whException.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=whException.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      </select></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td width="11%" height="15">&nbsp;</td>
      <td><select name="sort_by1_con">
        <option value="asc">Ascending</option>
        <%
	if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
      <td><select name="sort_by2_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
      <td><select name="sort_by3_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
	-->
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
        <font size="1">click to display employee list </font>			</td>
    </tr>
	
	<tr>
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
	<tr>
		<td height="10" >&nbsp;</td>
        <td colspan="3">
	
		<% if (WI.fillTextValue("show_all").equals("1"))
				strTemp = "checked";
			else
				strTemp = "";
				
		%>
		
	  		<input type="checkbox" name="show_all" value="1" <%=strTemp%>> 
				<font size="1">view all employees within this range</font>
		</td>       
      </tr>	  
    <tr>
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>   
     
  
  <% if (vRetResult != null &&  vRetResult.size() > 0) {%>
  
  <table width="100%" border="0" bgcolor="#FFFFFF" >
    <tr id="tr_print_header"  style="display:none" >
      <td width="100%" align="center">
			<h3><%=SchoolInformation.getSchoolName(dbOP,true,false)%></h3>		
			Bundy Employees<br>
			( <%=WI.fillTextValue("date_fr")%> - <%=WI.fillTextValue("date_to")%> )
			<div align="right">Date and time printed: <%=WI.getTodaysDateTime()%></div>
			
		</td>
	</td>
    </tr>
</table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  
  <table bgcolor="#FFFFFF" width="100%" id="tbl_print_btn">
  	<tr><td align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"><font size="1"></font></a>click to print &nbsp;&nbsp;</td>
	</tr>
  </table>
  <table width="100%" border="0" cellpadding="3" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder" >
    <tr bgcolor="#B9B292" id="tr_result_header"> 		
      <td height="20" colspan="6" align="center"  class="thinborder"><strong>LIST OF EMPLOYEES WITH EXCEPTION</strong></td>
    </tr>
    <tr>
      <td width="3%" class="thinborder">&nbsp;</td>
      <td width="8%" class="thinborder"><strong><font size="1">&nbsp;ID NUMBER</font></strong></td> 
      <td width="30%" height="30" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="34%" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
      <td width="16%" align="center" class="thinborder"><strong><font size="1">HOURS RENDERED</font></strong></td>
    </tr>
    <% 	int iCount = 1;
	   for (i = 0; i < vRetResult.size(); i+=7,iCount++){
		 %>
    <tr>
      <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i+1)%></td> 
      <td class="thinborder">&nbsp;	 
	  	<%=WebInterface.formatName( ((String)vRetResult.elementAt(i + 2)).toUpperCase(),
	  " ",((String)vRetResult.elementAt(i + 3)).toUpperCase(),4)%> 
	  </td> 
	  <% 
		 strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4),"");
		 if(strTemp.length() < 1 )
		  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5),"");	  
	  %>	
	  <td class="thinborder">&nbsp;<%=strTemp%></td>
  	  <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i+6)%></td>
    </tr>
    <%} //end for loop%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
  </table>
  
<% } // end vRetResult != null && vRetResult.size() > 0 %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="searchEmployee" >
  	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>