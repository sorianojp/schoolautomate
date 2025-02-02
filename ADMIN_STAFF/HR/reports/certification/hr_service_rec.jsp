<%@ page language="java" import="utility.*,java.util.Date, java.util.Vector,hr.HRStatsReports" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
	
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">

<style>

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
	
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
</style>
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function PrintPg()
{
<%if(strSchCode.startsWith("AUF")){%>
	location = "../../personnel/hr_personnel_service_rec_print.jsp?emp_id="+document.form_.emp_id.value+"&noted_by="+document.form_.noted_by.value+"&verified_by="+document.form_.verified_by.value;
<%}else{%>
	document.getElementById('header').deleteRow(0);
	document.getElementById('footer').deleteRow(0);
	document.getElementById('footer').deleteRow(0);
	window.print();
<%}%>
}

function ShowLists(){
	document.form_.show_list.value="1";
	document.form_.submit();
}

function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchID",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body marginheight="0" >
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_cert_service_rec.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","REPORTS AND STATISTICS",request.getRemoteAddr(),
														"hr_cert_service_rec.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
Vector vRetResult = null;
Vector vEmpRec = null;

hr.HRInfoServiceRecord hrSR = new hr.HRInfoServiceRecord();

strTemp = WI.fillTextValue("page_action");

if (WI.fillTextValue("show_list").equals("1")) {

	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");		

	if (vEmpRec == null || vEmpRec.size() == 0){
		strErrMsg = authentication.getErrMsg();
	}

	vRetResult = hrSR.operateOnServiceRecord(dbOP, request, 4);
	if (vRetResult == null || vRetResult.size()==0){
		strErrMsg = hrSR.getErrMsg();
	}else{
		if (vRetResult.size()== 1){
			strErrMsg = " No service Record";
		}
	}
}
		

%>
<form action="./hr_service_rec.jsp" method="post" name="form_" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="header">
<% if (strErrMsg != null) {%> 
<tr>
	<td height="25" colspan="3"> 
	&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%>	</td>
</tr>
<%}%> 
<tr>
	<td width="31%" height="25">Employee ID : 
	  <input name="emp_id" type="text"  class="textbox" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		size="16" value="<%=WI.fillTextValue("emp_id")%>"></td>
    <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" border="0"></a></td>
    <td width="64%"><a href="javascript:ShowLists()"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
</tr>
<%if(strSchCode.startsWith("AUF")){%>
<tr>
  <td height="25" colspan="3">Verified by:&nbsp;
  	<input type="text" name="verified_by" value="<%=WI.fillTextValue("verified_by")%>" size="32" class="textbox"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:12px"></td>
</tr>
<tr>
  <td height="25" colspan="3">Noted by:&nbsp;
  	<input type="text" name="noted_by" value="<%=WI.fillTextValue("noted_by")%>" size="32" class="textbox"
		  			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:12px"></td>
</tr>
<%}%>
</table>
<% if (vRetResult != null && vRetResult.size() > 1) { %>

<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" >
<tr>
	<td><div align="center"><br>
	  <strong><font size="3">SERVICE RECORD<br>
	  <%=WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), 
	  					(String)vEmpRec.elementAt(3),4).toUpperCase()%></font></strong>
	  <br><br>
	  </div></td>
</tr>
</table>

<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
          <tr bgcolor="#FFFFFF"> 
            <td width="24%" align="center" class="thinborder"><strong>POSITION</strong></td>
            <td width="7%" align="center" class="thinborder"><strong>STATUS</strong></td>
            <td width="27%" align="center" class="thinborder"><strong><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%>/ 
              UNIT</strong></td>
            <td width="27%" align="center" class="thinborder"><strong>INCLUSIVE 
              DATES</strong></td>
            <td width="15%" align="center" class="thinborder"><strong>REMARKS</strong></td>
          </tr>
          <%
		  String[] astrPTFT = {"PT", "FT"};
		  for (int i = 1; i < vRetResult.size(); i +=31){
		  	strTemp = (String)vRetResult.elementAt(i + 6);
			if (strTemp == null) 
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 8));
		  %>
          <tr bgcolor="#FFFFFF"> 
            <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
            <td class="thinborder">
							<%=astrPTFT[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 28),"1"))]%><%=((String)vRetResult.elementAt(i+4)).substring(0,1)%></td>
            <td class="thinborder"><%=strTemp%></td>
            <td class="thinborder">
				<%=WI.formatDate((String)vRetResult.elementAt(i + 17),10)%>
			<% if ((String)vRetResult.elementAt(i + 18) != null) {%>
				<%=" - " + WI.formatDate((String)vRetResult.elementAt(i + 18),10)%>
			<%}else{%> 
				<%=" - to date "%>							
			<%}%>
			</td>
            <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 29),"&nbsp;")%></td>
          </tr>
          <% } // end for loop %>
  </table>  
  
  
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <% if (vRetResult!= null) {%>
    <tr>
      <td width="45%">&nbsp;</td>
      <td width="55%" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2"><div align="center"><font size="1"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" width="58" height="26" border="0"></a>click 
      to print List</font></div></td> 
    </tr>
    <%}
	}%>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="show_list" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>