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
<title>SSS Quarterly remittance</title>
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
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderLEFTRIGHT {
	border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}


function PrintPg() {
	document.form_.print_pg.value = "1";
	this.SubmitOnce('form_');
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRTransmittal" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	String strPayrollPeriod  = null;

//add security here.
if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./phic_quarterly_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Slip main","sss_quarterly.jsp");

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
														"sss_quarterly.jsp");
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
	PRTransmittal PRTransmit = new PRTransmittal(request);
	
	String[] astrMonth = {"January","February","March","April","May","June","July",
							"August", "September","October","November","December"};
							
	String[] astrPtFt = {"PART-TIME","FULL-TIME"};
	
	String[] astrQuarterName = {"January - March", "April - June", "July - September", "October - December"};
	
	double dTemp = 0d;
	
	double dGrandTotal = 0d;
	
	double dEEOfficeTotal = 0d;
	double dEROfficeTotal = 0d;
	double dECOfficeTotal = 0d;
	
	double dEEStatusTotal = 0d;
	double dERStatusTotal = 0d;
	double dECStatusTotal = 0d;
	
	double dEEGrandTotal = 0d;
	double dERGrandTotal = 0d;
	double dECGrandTotal = 0d;
	
	boolean bolPtFtHeader = true;
	boolean bolShowHeader = true;
	
	boolean bolPtFtTotal = false;
	boolean bolOfficeTotal = false;
	boolean bolIncremented = false;
	boolean bolSameEmp = false;

	double dPS1 = 0d;
	double dPS2 = 0d;
	double dPS3 = 0d;

	double dES1 = 0d;
	double dES2 = 0d;
	double dES3 = 0d;

	boolean bolFirst = false;
	boolean bolSecond = false;
	boolean bolThird = false;
	
	String strMonth  = null;
	int iMonth = 0;
	
	int i = 0;
	int iTemp = 0;
	String strPS = null;
	String strES = null;
	String strEmpIndex = null;
	String strBracket1 = null;
	String strBracket2 = null;
	String strBracket3 = null;
	
	if(WI.fillTextValue("searchEmployee").equals("1")){
		vRetResult = PRTransmit.SSSTransmittal(dbOP);
		if(vRetResult == null){
			strErrMsg = PRTransmit.getErrMsg();
		}else{	
			iSearchResult = PRTransmit.getSearchCount();
		}
	}
	//for (i = 0; i < 32;i++){
	//	System.out.println("");
	//}
	
	if(strErrMsg == null) 
	strErrMsg = "";
%>
<body  class="bgDynamic">
<form name="form_" method="post" action="./sss_quarterly.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL: SSS PREMIUM QUARTERLY REMITTANCES PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="5"><font size="1"><a href="./philhealth_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="23" colspan="5"><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Quarter and Year </td>
      <td colspan="3"> 
	    <select name="quarter">
		<%for(i = 0; i < 4; i++){
		  	if(WI.fillTextValue("quarter").equals(Integer.toString(i))){
		%>			
			<option value="<%=i%>" selected><%=astrQuarterName[i]%></option>
			<%}else{%>
			<option value="<%=i%>"><%=astrQuarterName[i]%></option>
			<%}%>
		<%}%>
        </select>
        - 
        <select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td colspan="3"><font color="#000000" ><strong>
        <select name="pt_ft" onChange="ReloadPage();">
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
        </select>
      </strong></font></td>
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
      <td>Employer name </td>
      <td colspan="3">
			<select name="employer_index" onChange="ReloadPage();">
<%
String strEmployer = WI.fillTextValue("employer_index");
boolean bolIsDefEmployer = false;
java.sql.ResultSet rs = null;
strTemp = "select employer_index,employer_name,is_default from pr_employer_profile where is_del = 0 order by is_default desc";
rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	strTemp = rs.getString(1);
	if(strEmployer.length() == 0 || strEmployer.equals(strTemp)) {
		strErrMsg = " selected";
		if(rs.getInt(3) == 1)
			bolIsDefEmployer = true;
		if(strEmployer.length() == 0)
			strEmployer = strTemp;
	}
	else	
		strErrMsg = "";
		
%>			<option value="<%=strTemp%>" <%=strErrMsg%>><%=rs.getString(2)%></option>
<%}
rs.close();
%>      </select></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3"><!--
			<select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
			</select> 
			-->
          <select name="c_index" onChange="ReloadPage();">
        <option value="">N/A</option>
<% 
if(bolIsDefEmployer)
	strTemp = " from college where is_del= 0 and not exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.c_index = college.c_index and employer_index <>"+strEmployer+")";
else
	strTemp = " from college where is_del= 0 and exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.c_index = college.c_index and employer_index ="+strEmployer+")";
%>
        <%=dbOP.loadCombo("c_index","c_name", strTemp,strCollegeIndex,false)%>
      </select>
      </td>
    </tr>
		<%if(strCollegeIndex.length() == 0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3"><!-- <select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> 
				-->
          <select name="d_index" onChange="ReloadPage();">
        <option value="">N/A</option>
				<% 
				if(bolIsDefEmployer)
					strTemp = " from department where is_del= 0 and (c_index is null or c_index = 0) and not exists(select * from pr_employer_mapping " +
										"where pr_employer_mapping.d_index = department.d_index and employer_index <> "+ strEmployer + ")";
				else
					strTemp = " from department where is_del= 0 and (c_index is null or c_index = 0) and exists(select * from pr_employer_mapping " +
										"where pr_employer_mapping.d_index = department.d_index and employer_index ="+strEmployer+")";
				%>
        <%=dbOP.loadCombo("d_index","d_name", strTemp,WI.fillTextValue("d_index"),false)%>
      </select>
      </td>
    </tr>
		<%}%>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%" colspan="3">
			<!--
			<a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>
	<%if (vRetResult != null && vRetResult.size() > 0 ){	
	%>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18"><div align="right"><font size="2"> Number of Employees Per 
          Page : 
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 15; i <=40 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
    </tr> 
  </table>	
 
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td><hr size="1" color="#000000"></td>
  </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
    <td class="thinborderBOTTOM"><div align="center">NHIP PREMIUM CONRIBUTIONS </div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">  
  <tr>
    <td width="1%" class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td colspan="3" align="center" class="thinborderBOTTOMLEFT">NAME OF EMPLOYEES </td>
    <td width="7%" rowspan="2" align="center" class="thinborderBOTTOMLEFT">PIN / SSS </td>
    <td colspan="3" align="center" class="thinborderBOTTOMLEFT">BRACKET MONTHLY </td>
    <td colspan="2" align="center" class="thinborderBOTTOMLEFT">1ST MONTH </td>
    <td colspan="2" align="center" class="thinborderBOTTOMLEFT">2ND MONTH</td>
    <td colspan="2" align="center" class="thinborderBOTTOMLEFT">3RD MONTH</td>
    <td width="11%" colspan="3" class="thinborderBOTTOMLEFTRIGHT"><div align="center">REMARKS</div></td>
    </tr>
  <tr>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
    <td width="8%" class="thinborderBOTTOMLEFT">SURNAME</td>
    <td width="12%" class="thinborderBOTTOMLEFT">GIVEN NAME </td>
    <td width="8%" class="thinborderBOTTOMLEFT">MI</td>
    <td width="6%" align="center" class="thinborderBOTTOMLEFT">1ST</td>
    <td width="5%" align="center" class="thinborderBOTTOMLEFT">2ND</td>
    <td width="7%" align="center" class="thinborderBOTTOMLEFT">3RD</td>
    <td width="6%" align="center" class="thinborderBOTTOMLEFT">PS</td>
    <td width="6%" align="center" class="thinborderBOTTOMLEFT">ES</td>
    <td width="6%" align="center" class="thinborderBOTTOMLEFT">PS</td>
    <td width="6%" align="center" class="thinborderBOTTOMLEFT">ES</td>
    <td width="5%" align="center" class="thinborderBOTTOMLEFT">PS</td>
    <td width="6%" align="center" class="thinborderBOTTOMLEFT">ES</td>
    <td colspan="3" class="thinborderBOTTOMLEFTRIGHT"><font size="1">S-Separated, NE-No Earnings, NH-Newly Hired</font></td>
    </tr>
  <%int iCount = 1;  	
  for(i = 1; i < vRetResult.size();iCount++){
		iTemp = i;
		bolFirst = false;
		bolSecond = false;
		bolThird = false;
		strBracket1 = null;
		strBracket2 = null;
		strBracket3 = null;
		strEmpIndex = (String)vRetResult.elementAt(i);		
  %>
  <tr>
    <td class="thinborderBOTTOMLEFT"><%=iCount%></td>
    <td class="thinborderBOTTOMLEFT"><span class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+6)).toUpperCase()%></span></td>
    <td class="thinborderBOTTOMLEFT"><span class="thinborderBOTTOMLEFT">&nbsp;<%=((String)vRetResult.elementAt(i+4)).toUpperCase()%></span></td>
	<%
		strTemp = (String)vRetResult.elementAt(i+5);
		strTemp = WI.getStrValue(strTemp,"");
		if(strTemp.length() > 0)
			strTemp = strTemp.substring(0,1);	
	%>	
    <td class="thinborderBOTTOMLEFT"><span class="thinborderBOTTOMLEFT">&nbsp;<%=(strTemp).toUpperCase()%>.</span></td>
    <td class="thinborderBOTTOMLEFT">&nbsp;</td>
		<% for(; i < vRetResult.size();){
	  strMonth = (String)vRetResult.elementAt(i+13);	  
	  iMonth = Integer.parseInt(strMonth);
	  strMonth = Integer.toString((iMonth%3)+1);
		if(!strEmpIndex.equals((String)vRetResult.elementAt(i)))
			break;

	  if(strMonth.equals("1")){
		  strBracket1 = (String)vRetResult.elementAt(i+12);
		  i= i + 14;
		  bolIncremented = true;
		  bolFirst = true;			
	  }else
		  strBracket1 = "";	  

	   if(i >= vRetResult.size()){
	  		break;
	 	 }

		if(!strEmpIndex.equals((String)vRetResult.elementAt(i)))
			break;
		 
	  // okay here is the logic... 
		strMonth = (String)vRetResult.elementAt(i+13);
		iMonth = Integer.parseInt(strMonth);
		strMonth = Integer.toString((iMonth%3)+1);
		if(strMonth.equals("2")){
			strBracket2 = (String)vRetResult.elementAt(i+12);
			i = i + 14;
			bolIncremented = true;
			bolSecond = true;
		}else
			strBracket2 = "";
   
	  
		if(i >= vRetResult.size()){
	  		break;
	 	 }

		if(!strEmpIndex.equals((String)vRetResult.elementAt(i)))
			break;
	  
			strMonth = (String)vRetResult.elementAt(i+13);
			iMonth = Integer.parseInt(strMonth);
			strMonth = Integer.toString((iMonth%3)+1);
			if(strMonth.equals("3")){
					strBracket3 = (String)vRetResult.elementAt(i+12);
					i = i + 14;
				bolIncremented = true;
				bolThird = true;
			}else
				strBracket3 = "";
				
			break;
			}
	  %>
		<td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strBracket1,"&nbsp;")%>&nbsp;</td>
		<td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strBracket2,"&nbsp;")%>&nbsp;</td>
		<td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue(strBracket3,"&nbsp;")%>&nbsp;</td>
	<%
  	if(bolFirst){
			strPS = (String)vRetResult.elementAt(iTemp+10);		
	  }else
	  	strPS ="";
	%>
    <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strPS,true)%>&nbsp;</td>
	<%
  	if(bolFirst){	  	
			strES = (String)vRetResult.elementAt(iTemp+11);
			iTemp = iTemp + 14;
	  }else
	  	strES ="";
	%>
    <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strES,true)%>&nbsp;</td>
	<%
  	if(bolSecond){
			strPS = (String)vRetResult.elementAt(iTemp+10);		
	  }else
	  	strPS ="";
	%>
    <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strPS,true)%>&nbsp;</td>
	<%
  	if(bolSecond){
			strES = (String)vRetResult.elementAt(iTemp+11);
			iTemp = iTemp + 14;
	  }else
	  	strES ="";
	%>
    <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strES,true)%>&nbsp;</td>
	<%
  	if(bolThird){
			strPS = (String)vRetResult.elementAt(iTemp+10);		
	  }else
	  	strPS ="";
	%>
    <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strPS,true)%>&nbsp;</td>
	<%
  	if(bolThird){
			strES = (String)vRetResult.elementAt(iTemp+11);
	  }else
	  	strES ="";
	%>
    <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat(strES,true)%>&nbsp;</td>
    <td colspan="3" class="thinborderBOTTOMLEFTRIGHT"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="33%">&nbsp;</td>
        <td width="33%"class="thinborderLEFTRIGHT">&nbsp;</td>
        <td width="33%">&nbsp;</td>
      </tr>
    </table></td>
  </tr>
   <% 
   if(!bolIncremented){
  		break;
		}
  }// outer for loop%>
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
    <td colspan="3">&nbsp;</td>
  </tr>
</table>
  
  <%} // if (vRetResult != null && vRetResult.size() > 0 )%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr>
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
    <td width="50%" height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>