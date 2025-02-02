<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn, payroll.PReDTRME" %>
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
<title>Non Taxable Income for the Period</title>
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
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.searchEmployee.value = "";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function loadSalPeriods() {
	var strMonth = document.form_.month_of.value;
	var strYear = document.form_.year_of.value;
	var strWeekly = null;
	
	if(document.form_.is_weekly){
		if(document.form_.is_weekly.checked)
			strWeekly = "1";
		else
			strWeekly = "";
	}
	
	var objCOAInput = document.getElementById("sal_periods");
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
							 "&year_of="+strYear+"&is_weekly="+strWeekly+"&onchange=ReloadPage()";

	this.processRequest(strURL);
}

</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" 	method="post" action="period_non_tax_income.jsp">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
	int iSearchResult = 0;
	int i = 0;
	boolean bolHasTeam = false;
	//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./period_non_tax_income_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Non Taxable Income(Period)","period_non_tax_income.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
														"Payroll","REPORTS",request.getRemoteAddr(),
														"period_non_tax_income.jsp");
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
	ReportPayrollExtn RptPay = new ReportPayrollExtn(request);
	PReDTRME prEdtrME = new PReDTRME();
	Vector vRetResult    = null;
	Vector vSalaryPeriod = null;//detail of salary period.
	String[] astrTaxStatus = {"Zero Exemption","Single","Head of the Family","Married","Not Set"};
	String[] astrExemptionName    = {"Zero", "Single","Head of Family", "Head of Family 1 Dependent (HF1)", 
																	"Head of Family 2 Dependents (HF2)","Head of Family 3 Dependents (HF3)", 
																	"Head of Family 2 Dependents (HF4)", "Married Employed", 																	 
																	 "Married Employed 1 Dependent (ME1)", "Married Employed 2 Dependents (ME2)",
																	 "Married Employed 3 Dependents (ME3)", "Married Employed 4 Dependents (ME4)"};
	String[] astrExemptionVal     = {"0","1","2","21","22","23","24","3","31","32","33","34"};
		
	String[] astrSortByName    = {"Employee ID","Firstname","Lastname"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname"};
	String strTemp2  = null;

	if(WI.fillTextValue("searchEmployee").equals("1")){
	  vRetResult = RptPay.generatePeriodNonTaxable(dbOP);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}else{
			iSearchResult = RptPay.getSearchCount();
		}
	}
	 vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          PAYROLL - 
      REPORTS - NON TAXABLE INCOME FOR THE PERIOD PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;<font size="1"><a href="./non_tax_income_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font><strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="21%"> Salary Month/Year :</td>
      <td width="76%"> <select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Salary Period :</td>
      <td width="76%"><strong> 
				<label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px" onChange="ReloadPage();">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");
		
		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10){
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
			
			if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
          <%}//end of if condition.
		 }//end of for loop.%>
        </select>
				</label>
        </strong>
        <% 
				if(strHasWeekly.equals("1")){
					strTemp = WI.fillTextValue("is_weekly");
					if(strTemp.compareTo("1") == 0) 
						strTemp = " checked";
					else	
						strTemp = "";
				%>
        <input type="checkbox" name="is_weekly" value="1" <%=strTemp%> onClick="ReloadPage();">
        <font size="1">for weekly </font>
        <%}// check if the company has weekly salary type%>      </td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr> 
      <td width="3%" height="18">&nbsp;</td>
      <td width="18%">Tax Status:</td>
      <%
			strTemp = WI.fillTextValue("tax_status");
		%>
      <td width="79%"><select name="tax_status">
        <option value="">ALL</option>
        <%for(i = 0; i <= 11; ++i ){
				if(astrExemptionVal[i].equals(strTemp)){%>
        <option selected value="<%=astrExemptionVal[i]%>"><%=astrExemptionName[i]%></option>
        <%}else{%>
        <option value="<%=astrExemptionVal[i]%>"> <%=astrExemptionName[i]%></option>
        <%}
			}%>
      </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <%
		String strCollegeIndex = WI.fillTextValue("c_index");
	  %>
      <td> <%if(bolIsSchool){%>College<%}else{%>Division<%}%> </td>
      <td> <select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Department/Office</td>
      <td><select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select></td>
    </tr>
 		<%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>
      </td>
    </tr>
		<%}%>    
    <tr> 
      <td height="24" colspan="3"><hr size="1"></td>
    </tr>
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"> <select name="sort_by1">
          <option value="">N/A</option>
          <%=RptPay.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select></td>
      <td height="29"><select name="sort_by2">
          <option value="">N/A</option>
          <%=RptPay.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select></td>
      <td height="29"><select name="sort_by3">
          <option value="">N/A</option>
          <%=RptPay.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
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
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">
			<!--
			<a href="javascript:SearchEmployee()"> <img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"></a> 
			-->
			<input type="submit" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18"><div align="right"><font size="2"> 
<%if(!strSchCode.startsWith("EAC")){%>
	  <input type="checkbox" name="show_total" value="checked" <%=WI.fillTextValue("show_total")%>> 
	  Show Page total and Grand Total
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<%}%>	  

	  Number of Employees Per 
          Page :</font><font> 
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 15; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" width="58" height="26" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
    </tr>
    <%		
	int iPageCount = iSearchResult/RptPay.defSearchSize;		
	if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;
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
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" align="center" class="thinborderTOPLEFT">&nbsp;</td>
      <td align="center" class="thinborderTOPLEFT">&nbsp;</td>
      <td align="center" class="thinborderTOPLEFT">&nbsp;</td>
      <td colspan="4" align="center" class="thinborderTOPLEFT"><font size="1"><strong>Non Taxable Income </strong></font>        </td>
      <td align="center" class="thinborderTOPLEFT">&nbsp;</td>
      <td align="center" class="thinborderTOPRIGHT">&nbsp;</td>
    </tr>
    <tr> 
      <td width="5%" height="25" align="center" class="thinborderTOPLEFTBOTTOM">          <font size="1"><strong>COUNT 
              NO.</strong></font>      </td>
      <td width="26%" align="center" class="thinborderTOPLEFTBOTTOM">          <font size="1"><strong>Name</strong></font>      </td>
      <td width="10%" align="center" class="thinborderBOTTOMLEFT">          <strong><font size="1">Gross Pay </font></strong>      </td>
      <td width="9%" align="center" class="thinborderTOPLEFTBOTTOM">          <font size="1"><strong>Pag-ibig Premium </strong></font>      </td>
      <td width="9%" align="center" class="thinborderTOPLEFTBOTTOM">          <font size="1"><strong>SSS</strong></font>      </td>
      <td width="9%" align="center" class="thinborderTOPLEFTBOTTOM">          <font size="1"><strong>Phil. Health </strong></font>      </td>
      <td width="9%" align="center" class="thinborderTOPLEFTBOTTOM">          <font size="1"><strong>Union Dues </strong></font>      </td>
      <td width="11%" align="center" class="thinborder">          <strong><font size="1">Taxable Income </font></strong>      </td>
      <td width="12%" align="center" class="thinborderBOTTOMRIGHT">          <strong><font size="1">W/Tax</font></strong>      </td>
    </tr>
    <%
	int iRow = 1;
	for(i = 0; i < vRetResult.size(); i+=15, iRow ++){%>
    <tr> 
      <td height="19" class="thinborderNONE">&nbsp;<%=iRow%></td>
      <td class="thinborderNONE"><div align="left"><font size="1">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+11);
		strTemp = CommonUtil.formatFloat(strTemp,true);
	  %>	
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%>&nbsp;</font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+8);
		strTemp = CommonUtil.formatFloat(strTemp,true);
	  %>		  
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%>&nbsp;</font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+9);
		strTemp = CommonUtil.formatFloat(strTemp,true);
	  %>		  
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%>&nbsp;</font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+10);
		strTemp = CommonUtil.formatFloat(strTemp,true);
	  %>	
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%>&nbsp;</font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+13);
		strTemp = WI.getStrValue(strTemp,"0");
		strTemp = CommonUtil.formatFloat(strTemp,true);
	  %>	
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%>&nbsp;</font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+12);
		strTemp = CommonUtil.formatFloat(strTemp,true);
	  %>	
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%>&nbsp;</font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+5);
		strTemp = CommonUtil.formatFloat(strTemp,true);
	  %>							
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%>&nbsp;</font></div></td>
    </tr>
    <%}%>
  </table>
	<%}%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>  
  
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>