<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>GSIS LOANS MONTHLY REMITTANCES</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.thinborderBOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 9px;
}

TD.thinborderBOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 9px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
	font-size: 9px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}


function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}

function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2); //I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;

//add security here.
if (WI.fillTextValue("print_page").length() > 0){
  if(WI.fillTextValue("format").equals("2")){%>
	<jsp:forward page="./hdmf_remittance_print2.jsp" />
  <%}else{%>
    <jsp:forward page="./hdmf_remittance_print.jsp" />
<% 
return;}
}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","hdmf_monthly.jsp");

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
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"hdmf_monthly.jsp");
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

Vector vRetResult = null;
PRRemittance PRRemit = new PRRemittance(request);
double dTemp  = 0d;
double dLineTotal  = 0d;

String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};
					  
String[] astrPtFt = {"PART-TIME","FULL-TIME"};
String[] astrRemarks = {"A", "B", "C", "D", "E", ""};
int i = 0;
if(WI.fillTextValue("searchEmployee").equals("1")){
  vRetResult = PRRemit.HDMFMonthlyPremium(dbOP);
	if(vRetResult == null){
		strErrMsg = PRRemit.getErrMsg();
	}else{	
		iSearchResult = PRRemit.getSearchCount();
	}
}

if(strErrMsg == null) 
strErrMsg = "";
%>

<body  class="bgDynamic">
<form name="form_" method="post" action="./hdmf_monthly.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr  bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL : GSIS PREMIUM MONTHLY REMITTANCES PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="5"><font size="1"><a href="./remittances_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="23" colspan="5"><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Month and Year </td>
      <td colspan="3"> <select name="month_of">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select></td>
    </tr>
    
    	
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td colspan="3"><select name="pt_ft" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("pt_ft").equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
          <%}else if(WI.fillTextValue("pt_ft").equals("1")){%>
		  <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
          <%}else{%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
          <%}%>
        </select></td>
    </tr>	
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
	<%if(bolIsSchool){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3"><select name="employee_category" onChange="ReloadPage();">                    
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("employee_category").equals("0")){%>
		  <option value="0" selected>Non-Teaching</option>
          <option value="1">Teaching</option>          
          <%}else if (WI.fillTextValue("employee_category").equals("1")){%>
		  <option value="0">Non-Teaching</option>
          <option value="1" selected>Teaching</option>          
          <%}else{%>
		  <option value="0">Non-Teaching</option>
          <option value="1">Teaching</option>          
          <%}%>
        </select> </td>
    </tr>
	<%}%>
    
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3"> 
				<select name="c_index" onChange="loadDept();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3"> 
				<label id="load_dept">
				<select name="d_index" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> 
				</label></td>
    </tr>
    
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%" colspan="3"><a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a><font size="1">click 
        to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size() > 0 ){%>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr> 
      <td height="18"><div align="right"><font size="2"> Number of Employees / rows Per 
          Page :</font><font> 
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 5; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
    </tr>
    <%		
	int iPageCount = iSearchResult/PRRemit.defSearchSize;		
	if(iSearchResult % PRRemit.defSearchSize > 0) ++iPageCount;
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
	<%}%>
  </table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="15">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="15"><div align="center"><strong>GSIS  PREMIUM REMITTANCES <br>
          <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></div></td>
  </tr>
  <tr>
    <td colspan="15" class="thinborderBOTTOM">&nbsp;</td>
  </tr>
  <tr>
    <td rowspan="2" class="thinborderBOTTOMLEFT"><div align="center">EMPLOYEE NAME</div></td>
    <td rowspan="2" class="thinborderBOTTOMLEFT"><div align="center">MONTHLY SALARY</div></td>
    <td rowspan="2" class="thinborderBOTTOMLEFT"><div align="center">POLICY NUMBER </div></td>
    <td height="19" colspan="7" class="thinborderBOTTOMLEFT"><div align="center">SOCIAL INSURANCE CONTRIBUTIONS</div></td>
    <td colspan="4" class="thinborderBOTTOMLEFTRIGHT"><div align="center" class="thinborderBOTTOMLEFT">REMARKS</div></td>
    <td rowspan="2" class="thinborderBOTTOMLEFTRIGHT">TOTAL</td>
    </tr>
  <tr>
    <td height="27" class="thinborderBOTTOMLEFT"><div align="center">PS</div></td>
    <td class="thinborderBOTTOMLEFT"><div align="center">GS</div></td>
    <td class="thinborderBOTTOMLEFT">EMPLOYEES COMPENSATION </td>
    <td class="thinborderBOTTOMLEFT">OPTIONAL 1 </td>
    <td class="thinborderBOTTOMLEFT">OPTIONAL 2 </td>
    <td class="thinborderBOTTOMLEFT">OPTIONAL 3 </td>
    <td class="thinborderBOTTOMLEFT">ADDITIONAL INSURANCE </td>
    <td class="thinborderBOTTOMLEFT">UNLIMITED OPT. INS. </td>
    <td class="thinborderBOTTOMLEFT">HIP</td>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td class="thinborderBOTTOMLEFT">EDUCAT'L INSURANCE </td>
    </tr>
  <%int iCount = 1;
  for(i = 0; i < vRetResult.size();i+=16,iCount++){
 	 dLineTotal = 0d;
  %>
  
  <tr>
    <%
		strTemp = (String)vRetResult.elementAt(i+13);
	%>	
    <%
		strTemp = (String)vRetResult.elementAt(i+14);
		strTemp += " --<br>" + WI.getStrValue((String)vRetResult.elementAt(i+12),"");
	%>
    <td width="13%" height="23" class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+6)).toUpperCase()%></td>
    <td width="7%" class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+4)).toUpperCase()%></td>
    <td width="6%" class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+5)).toUpperCase()%></td>
    <% 
		strTemp = (String)vRetResult.elementAt(i+10);		
	%>
    <td width="3%" class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</div></td>
	<% 
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dLineTotal += dTemp;		
	%>
	<% strTemp = (String)vRetResult.elementAt(i+11);%>
    <td width="4%" class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</div></td>
	<% 
		strTemp = ConversionTable.replaceString((String)vRetResult.elementAt(i+11),",","");
		dTemp =  Double.parseDouble(WI.getStrValue(strTemp,"0"));
		dLineTotal += dTemp;
	%>	
    <td width="12%" class="thinborderBOTTOMLEFT"><div align="right"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</div></td>
	<td width="7%" class="thinborderBOTTOMLEFT">&nbsp;</td>
	<td width="7%" class="thinborderBOTTOMLEFT">&nbsp;</td>
	<td width="7%" class="thinborderBOTTOMLEFT">&nbsp;</td>
	<td width="8%" class="thinborderBOTTOMLEFT">&nbsp;</td>
	<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15),"5");
	%>	
    <td width="8%" class="thinborderBOTTOMLEFT"><strong>&nbsp;</strong></td>
    <td width="3%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="3%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="8%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="4%" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
  <%}%>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    </tr>
</table>
<%} // if (vRetResult != null && vRetResult.size() > 0 )%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr>
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
    <td width="50%" height="25">&nbsp;</td>
  </tr>
</table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>