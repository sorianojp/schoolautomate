<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn" %>
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
<title>Non Taxable Income for the Year</title>
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
function ViewRecords()
{
	document.form_.print_page.value="";	
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" 	method="post" action="year_non_tax_income.jsp">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	int i = 0;
	boolean bolHasTeam = false;
	//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<% if( WI.fillTextValue("format").equals("2") ){%>
		<jsp:forward page="./year_non_tax_income_print_eac.jsp" />
	<%}else{%>	
		<jsp:forward page="./year_non_tax_income_print.jsp" />
	<%}%>
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Non Taxable Income (Yearly)","year_non_tax_income.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"year_non_tax_income.jsp");
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
	Vector vRetResult = null;	
	String[] astrTaxStatus = {"Zero Exemption","Single","Head of the Family","Married","Not Set"};
	String[] astrExemptionName    = {"Zero", "Single","Head of Family", "Head of Family 1 Dependent (HF1)", 
																	"Head of Family 2 Dependents (HF2)","Head of Family 3 Dependents (HF3)", 
																	"Head of Family 2 Dependents (HF4)", "Married Employed", 																	 
																	 "Married Employed 1 Dependent (ME1)", "Married Employed 2 Dependents (ME2)",
																	 "Married Employed 3 Dependents (ME3)", "Married Employed 4 Dependents (ME4)"};
	String[] astrExemptionVal     = {"0","1","2","21","22","23","24","3","31","32","33","34"};
		
	String[] astrSortByName    = {"Employee ID","Firstname","Lastname"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname"};

	if(WI.fillTextValue("searchEmployee").length() > 0){
	  vRetResult = RptPay.generateYearNonTaxable(dbOP);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}else{
			iSearchResult = RptPay.getSearchCount();
		}
	}
	
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
        PAYROLL - 
        REPORTS -NON TAXABLE INCOME FOR THE YEAR PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1"><a href="./non_tax_income_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font>&nbsp;<strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="18">&nbsp;</td>
      <td>Year</td>
      <td><select name="year_of">
        <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
      </select>
	  
	  Month (range): 
	  <select name="month_fr">
		  <option></option>
          <%=dbOP.loadComboMonth(WI.getStrValue(WI.fillTextValue("month_fr"), "-1"))%> 
     </select> - 
	 <select name="month_to">
	 		<option></option>
          <%=dbOP.loadComboMonth(WI.getStrValue(WI.fillTextValue("month_to"), "-1"))%> 
     </select>
	  
	  
	  </td>
    </tr>
    <tr>
      <td width="3%" height="18"><div align="right"><font size="2"> </font></div></td>
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
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
			<%
				strTemp = "";
				if(WI.fillTextValue("inc_resigned").length() > 0 || request.getParameter("inc_resigned") == null)
					strTemp = " checked";
			%>
      <td><input type="checkbox" name="inc_resigned" value="1" <%=strTemp%>>
      include resigned employees in report</td>
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
      <td height="28" colspan="3"><hr size="1"></td>
    </tr>
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :<strong></strong></td>
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
<%if(strSchCode.startsWith("EAC")){%>
    <tr>
	<%
		strTemp = WI.fillTextValue("format");
	%>
      <td height="18" colspan="3">
        <div align="right">Print format
          <select name="format">
              <option value="2">Format 2</option>
<!--
              <%if(strTemp.equals("1")){%>
              <option selected value="1">Format 1</option>
              <%}else{%>
              <option value="1">Format 1</option>
              <%}%>
-->
            </select>
      </div></td>
    </tr>
<%}%>
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
		  <option value="100000">Print All in One Page</option>
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 35; i <=60 ; i++) {
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
      <td colspan="4" align="center" class="thinborderTOPLEFT"><font size="1"><strong>Non Taxable Income </strong></font></td>
      <td align="center" class="thinborderTOPLEFT">&nbsp;</td>
      <td align="center" class="thinborderTOPRIGHT">&nbsp;</td>
    </tr>
    <tr> 
      <td width="5%" height="25" align="center" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong>COUNT 
        NO.</strong></font></td>
      <td width="26%" align="center" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong>Name</strong></font></td>
      <td width="10%" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">Gross Pay </font></strong></td>
      <td width="9%" align="center" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong>Pag-ibig Premium </strong></font></td>
      <td width="9%" align="center" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong>SSS</strong></font></td>
      <td width="9%" align="center" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong>Phil. Health </strong></font></td>
      <td width="9%" align="center" class="thinborderTOPLEFTBOTTOM"><font size="1"><strong>Union Dues </strong></font></td>
      <td width="11%" align="center" class="thinborder"><strong><font size="1">Taxable Income </font></strong></td>
      <td width="12%" align="center" class="thinborderBOTTOMRIGHT"><strong><font size="1">W/Tax</font></strong></td>
    </tr>
    <%
	int iRow = 1;
	for(i = 0; i < vRetResult.size(); i+=16, iRow ++){%>
    <tr> 
      <td height="19" class="thinborderNONE">&nbsp;<%=iRow%></td>
      <td class="thinborderNONE"><div align="left"><font size="1">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+12);
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
	  	strTemp = (String)vRetResult.elementAt(i+11);
		strTemp = CommonUtil.formatFloat(strTemp,true);
	  %>	
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%>&nbsp;</font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+14);
		strTemp = WI.getStrValue(strTemp,"0");
		strTemp = CommonUtil.formatFloat(strTemp,true);
	  %>	
      <td class="thinborderNONE"><div align="right"><font size="1"><%=strTemp%>&nbsp;</font></div></td>
      <%
	  	strTemp = (String)vRetResult.elementAt(i+13);
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