<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary For Bank</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.noBorder {
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
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

function ViewRecords()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
}

</script>
<body>
<form name="form_" 	method="post" action="./payroll_summary_bystatus.jsp">
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME" %>
<%  WebInterface WI = new WebInterface(request);

if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./payroll_summary_bystatus_print.jsp" />
<% return;}
	
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	int i = 0;

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Summary by status","payroll_summary_bystatus.jsp");
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
//end of authenticaion code.

	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	
	Vector vRetResult = null;
	Vector vRetLoans  = new Vector();
	ReportPayroll RptPay = new ReportPayroll(request);
	String strPayrollPeriod  = null;
	
	double dPeriodRate     = 0d;
	double dGrossPay       = 0d;
	double dOtherDeduction = 0d;
	double dTotalDeduction = 0d;
	double dNetPay         = 0d;
	double dTemp           = 0d;
	/// USE THIS TO EASILY CONTROL THE NUMBER OF ROWS TO display for deductions.
	int iTotRows = 3;
	String strPTFT = WI.getStrValue(WI.fillTextValue("pt_ft"),"3");
	String strCategory = WI.getStrValue(WI.fillTextValue("employee_category"),"4");
	String[] astrPTFT = {"Part - time","Full - time"};
	String[] astrCategory = {"Non-Teaching","Teaching","Non-Teaching w/ Teaching Load"};
	String strTemp2 = null;
	
	if (WI.fillTextValue("searchEmployee").length() > 0) {
	vRetResult = RptPay.searchByStatusExt(dbOP);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}else{
			iSearchResult = RptPay.getSearchCount();
		}
	}
	if(WI.fillTextValue("year_of").length() > 0) {
		vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	}
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5"><div align="center"><font color="#000000" ><strong>:::: 
          PAYROLL: PAYROLL SUMMARY (BY STATUS) PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td colspan="3"> <select name="month_of">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">Salary Period</td>
      <td width="77%" colspan="3"><strong>
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");		
		
		for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%> </option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%></option>
          <%}//end of if condition.		  
		 }//end of for loop.%>
        </select>
      </strong></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Position</td>
      <td height="10" colspan="3"><select name="emp_type_index"  onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%> </select> </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee Status</td>
      <td height="10" colspan="3">
        <select name="pt_ft" onChange="ReloadPage();">
          <option value="">ALL</option>
		  <%for(i = 0; i < 2; i++){
			  if(Integer.parseInt(strPTFT) == i)
				  strTemp = "selected";
			  else
				  strTemp = "";
		  %>
          <option value="<%=i%>" <%=strTemp%>><%=astrPTFT[i]%></option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee Category</td>
      <td height="10" colspan="3"> 
        <select name="employee_category" onChange="ReloadPage();">
		<option value="">ALL</option>
          <%for(i = 0;i<3;i++){
			  if(Integer.parseInt(strCategory) == i)
				  strTemp = "selected";
			  else
				  strTemp = "";
		  %>
          <option value="<%=i%>" <%=strTemp%>><%=astrCategory[i]%></option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee Tenure</td>
      <td height="10" colspan="3"><select name="status"  onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("status"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Account Type</td>
      <td height="10" colspan="3"><select name="is_atm" onChange="ReloadPage();">
          <option value="0" selected>Non-ATM Account</option>
          <%if (WI.fillTextValue("is_atm").equals("1")){%>
          <option value="1" selected>ATM Account</option>
          <%}else{%>
          <option value="1">ATM Account</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">College</td>
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
      <td height="10" colspan="3"><select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Department/Office</td>
      <td height="10" colspan="3"><select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3"><input type="image" onClick="ViewRecords();" src="../../../images/form_proceed.gif"> 
      </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
  </table>
  <% if (vRetResult != null && vRetResult.size() > 1 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24"><div align="center">&nbsp;</div></td>
      <td height="24"><font size="1">&nbsp;</font></td>
      <td height="24"><div align="center"><strong><font color="#0000FF">PAYROLL 
          DATE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></div></td>
      <td height="24" colspan="2">&nbsp;</td>
    </tr>
        <%		
		int iPageCount = iSearchResult/RptPay.defSearchSize;		
		if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>
    <tr> 
      <td colspan="5"><div align="right">Jump To page: 
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
        </div></td>
    </tr>
	<%}%>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="15%"><div align="center"><font size="1"><strong>ACCOUNT # / EMPLOYEE 
          NAME</strong></font></div></td>
      <td width="69%"><div align="center"><font size="1"></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>TOTAL </strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>NET PAY</strong></font></div></td>
    </tr>
    <% int iCount = 0;
		int iRow = 0;
	if (vRetResult != null && vRetResult.size() > 0){
	  for(i = 0,iCount=1; i < vRetResult.size(); i += 33,++iCount){
		vRetLoans   = (Vector) vRetResult.elementAt(i+29);
		//vFacultySalary = (Vector) vRetResult.elementAt(i+32);
		iRow = 1;
	  %>
    <tr> 
      <td valign="top" class="noBorder"><div align="right"><%=iCount%>&nbsp;</div></td>
      <td height="36" valign="top" class="noBorder"> &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1)," ")%><br> &nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+2)), (String)vRetResult.elementAt(i+3),
							((String)vRetResult.elementAt(i+4)), 4)%><br> &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5)," ")%> </td>
      <td valign="top"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr valign="top"> 
            <td width="9%" height="15" class="noBorder">Basic</td>
            <td width="9%" class="noBorder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vRetResult.elementAt(i+8),true),"")%>&nbsp; </div></td>
            <td width="9%" class="noBorder">&nbsp;Salary</td>
            <%  strTemp = CommonUtil.formatFloat(((String)vRetResult.elementAt(i+9)),true);
			    if(!((String)vRetResult.elementAt(i+28)).equals("1")){				
				dGrossPay += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				}				
			%>
            <td width="9%" class="noBorder"><div align="right"> <%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
            <%if (vRetResult.elementAt(i+24) != null && Double.parseDouble((String)vRetResult.elementAt(i+24)) > 0){
              strTemp = "COLA";
            }else{
              strTemp = ""; 
            }%>
            <td width="9%" class="noBorder"><%=strTemp%>&nbsp;</td>
            <%if (vRetResult.elementAt(i+24) != null){
				if (Double.parseDouble((String)vRetResult.elementAt(i+24)) > 0){
					dGrossPay += Double.parseDouble((String)vRetResult.elementAt(i+24));
					strTemp = CommonUtil.formatFloat(((String)vRetResult.elementAt(i+24)),true);
				}else{
					strTemp = "";
				}
			  }
			%>
            <td width="9%" class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
            <%if (vRetResult.elementAt(i+10) != null && Double.parseDouble((String)vRetResult.elementAt(i+10)) > 0){
				strTemp = "OVERTIME";
			}else{
				strTemp = "";
			}%>
            <td width="9%" class="noBorder"><%=WI.getStrValue(strTemp,"")%></td>
            <%if (vRetResult.elementAt(i+10) != null){				
				if (Double.parseDouble((String)vRetResult.elementAt(i+10)) > 0){
					dGrossPay += Double.parseDouble((String)vRetResult.elementAt(i+10));
					strTemp = CommonUtil.formatFloat(((String)vRetResult.elementAt(i+10)),true);
				}else{
					strTemp = "";
				}		
			  }
			%>
            <td width="8%" class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
            <%if (vRetResult.elementAt(i+27) != null && Double.parseDouble((String)vRetResult.elementAt(i+27)) > 0)
	              strTemp = "OVERLOAD / PART TIME"; 
              else
	              strTemp = "";
              %>
            <td width="13%" class="noBorder">&nbsp;<%=WI.getStrValue(strTemp,"")%></td>
            <%if (vRetResult.elementAt(i + 27) != null){				
				if (Double.parseDouble((String)vRetResult.elementAt(i+27)) > 0){
					dGrossPay += Double.parseDouble((String)vRetResult.elementAt(i+27));
					strTemp = CommonUtil.formatFloat(((String)vRetResult.elementAt(i+27)),true);
				}else{
					strTemp = "";
				}
			 }%>
            <td width="16%" class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
          </tr>
          <tr valign="top"> 
            <%if (vRetResult.elementAt(i+20) != null && Double.parseDouble((String)vRetResult.elementAt(i+20)) > 0){
              	strTemp = "TxWitheld";
              }else{
				strTemp = "";
              }%>
            <td width="9%" class="noBorder"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
            <%if (vRetResult.elementAt(i+20) != null){				
				if (Double.parseDouble((String)vRetResult.elementAt(i+20)) > 0){
					dTotalDeduction += Double.parseDouble((String)vRetResult.elementAt(i+20));
					strTemp = CommonUtil.formatFloat(((String)vRetResult.elementAt(i+20)),true);
				}else{
					strTemp = "";
				}
			}%>
            <td width="9%" class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
            <%if (vRetResult.elementAt(i+14) != null && Double.parseDouble((String)vRetResult.elementAt(i+14)) > 0){
              	strTemp = "Pag-Ibig";
              }else{
	            strTemp = "";
              }%>
            <td class="noBorder"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
            <%if (vRetResult.elementAt(i+14) != null){				
				if (Double.parseDouble((String)vRetResult.elementAt(i+14)) > 0){
				  dTotalDeduction += Double.parseDouble((String)vRetResult.elementAt(i+14));
				  strTemp = CommonUtil.formatFloat(((String)vRetResult.elementAt(i+14)),true);
				}else{
				  strTemp = "";
				}
            }%>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
            <%if (vRetResult.elementAt(i+12) != null && Double.parseDouble((String)vRetResult.elementAt(i+12)) > 0)
    	          strTemp = "SSS";
                else
	              strTemp = "";
              %>
            <td class="noBorder"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
            <%if (vRetResult.elementAt(i+12) != null){				
				if (Double.parseDouble((String)vRetResult.elementAt(i+12)) > 0){
					dTotalDeduction += Double.parseDouble((String)vRetResult.elementAt(i+12));
					strTemp = CommonUtil.formatFloat(((String)vRetResult.elementAt(i+12)),true);
				}else{
					strTemp = "";
				}
			}%>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
            <%if (vRetResult.elementAt(i+13) != null && Double.parseDouble((String)vRetResult.elementAt(i+13)) > 0){
	            strTemp = "PHealth";
              }else{
              	strTemp = "";
              }%>
            <td class="noBorder"><%=WI.getStrValue(strTemp,"")%></td>
            <%if (vRetResult.elementAt(i+13) != null){				
			  if (Double.parseDouble((String)vRetResult.elementAt(i+13)) > 0){
				  dTotalDeduction += Double.parseDouble((String)vRetResult.elementAt(i+13));
				  strTemp = CommonUtil.formatFloat(((String)vRetResult.elementAt(i+13)),true);
			  }else{
				  strTemp = "";
			  }			  
		  }%>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
            <%if (vRetResult.elementAt(i+7) != null && Double.parseDouble((String)vRetResult.elementAt(i+7)) > 0){
              strTemp = "Honorarium";
            }else{
              strTemp = "";
            }%>
            <td class="noBorder">&nbsp;<%=WI.getStrValue(strTemp,"")%></td>
            <%if (vRetResult.elementAt(i+7) != null){				
				  if (Double.parseDouble((String)vRetResult.elementAt(i+7)) > 0){
					dGrossPay += Double.parseDouble((String)vRetResult.elementAt(i+7));
					strTemp = CommonUtil.formatFloat(((String)vRetResult.elementAt(i+7)),true);
				  }else{
					strTemp = "";
				  }
  		    }%>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
          </tr>
          <%if (vRetLoans != null && vRetLoans.size() > 0){%>
          <tr valign="top"> 
            <td colspan="2" class="noBorder"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <% for(int j = 0; j < vRetLoans.size();j+=3,++iRow){%>
                <tr> 
                  <%  
				    strTemp = (String) vRetLoans.elementAt(j);
					strTemp = ConversionTable.replaceString(strTemp," ","");										
					  if (strTemp.length() > 5 && (vRetLoans.elementAt(j+2) != null) ){							
						strTemp = strTemp.substring(0,5);
					  }
					strTemp += WI.getStrValue((String)vRetLoans.elementAt(j+2),"&nbsp;");
				  %>
                  <td width="50%" valign="top" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
                  <%
				  	strTemp = ConversionTable.replaceString((String)vRetLoans.elementAt(j+1),",","");					
				    dTotalDeduction += Double.parseDouble(strTemp);
				  %>
                  <td width="50%" class="noBorder"> <div align="right"> <%=WI.getStrValue((String) vRetLoans.elementAt(j+1),"&nbsp;")%>&nbsp;</div></td>
                </tr>
                <% if (iRow == iTotRows){
						iRow = 1;
						break;
					}
				  }/// end for loop
				%>
              </table></td>
            <td colspan="2" class="noBorder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
                <% if (vRetLoans != null && vRetLoans.size() > (3*iTotRows)){
                   for(int j = (3*iTotRows); j < vRetLoans.size();j+=3,++iRow){%>
                <tr> 
                  <%  
				    strTemp = (String) vRetLoans.elementAt(j);
					strTemp = ConversionTable.replaceString(strTemp," ","");										
					  if (strTemp.length() > 5 && (vRetLoans.elementAt(j+2) != null) ){							
						strTemp = strTemp.substring(0,5);
					  }
					strTemp += WI.getStrValue((String)vRetLoans.elementAt(j+2),"&nbsp;");
				  %>
                  <td width="50%" valign="top" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
                  <%
				  	strTemp = ConversionTable.replaceString((String)vRetLoans.elementAt(j+1),",","");					
				    dTotalDeduction += Double.parseDouble(strTemp);
				  %>
                  <td width="50%" class="noBorder"><div align="right"><%=WI.getStrValue((String) vRetLoans.elementAt(j+1),"&nbsp;")%>&nbsp;</div></td>
                </tr>
                <% if (iRow == iTotRows){
						iRow = 1;
						break;
					}
				  }/// end for loop
				}//if (vRetLoans != null && vRetLoans.size() > 0) %>
              </table></td>
            <td colspan="2" class="noBorder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
                <% if (vRetLoans != null && vRetLoans.size() > (6*iTotRows)){
                   for(int j = (6*iTotRows); j < vRetLoans.size();j+=3,++iRow){%>
                <tr> 
                  <%  
				    strTemp = (String) vRetLoans.elementAt(j);
					strTemp = ConversionTable.replaceString(strTemp," ","");										
					  if (strTemp.length() > 5 && (vRetLoans.elementAt(j+2) != null) ){							
						strTemp = strTemp.substring(0,5);
					  }
					strTemp += WI.getStrValue((String)vRetLoans.elementAt(j+2),"&nbsp;");
				  %>
                  <td width="50%" valign="top" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
                  <%
				  	strTemp = ConversionTable.replaceString((String)vRetLoans.elementAt(j+1),",","");					
				    dTotalDeduction += Double.parseDouble(strTemp);
				  %>
                  <td width="50%" class="noBorder"> <div align="right"> <%=WI.getStrValue((String) vRetLoans.elementAt(j+1),"&nbsp;")%>&nbsp;</div></td>
                </tr>
                <% if (iRow == iTotRows){
						iRow = 1;
						break;
					}
				  }/// end for loop
				}//if (vRetLoans != null && vRetLoans.size() > 0) %>
              </table></td>
            <td colspan="2" class="noBorder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
                <% if (vRetLoans != null && vRetLoans.size() > (9*iTotRows)){
                   for(int j = (9*iTotRows); j < vRetLoans.size();j+=3,++iRow){%>
                <tr> 
                  <%  
				    strTemp = (String) vRetLoans.elementAt(j);
					strTemp = ConversionTable.replaceString(strTemp," ","");										
					  if (strTemp.length() > 5 && (vRetLoans.elementAt(j+2) != null) ){							
						strTemp = strTemp.substring(0,5);
					  }
					strTemp += WI.getStrValue((String)vRetLoans.elementAt(j+2),"&nbsp;");
				  %>
                  <td width="52%" valign="top" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
                  <%
				  	strTemp = ConversionTable.replaceString((String)vRetLoans.elementAt(j+1),",","");					
				    dTotalDeduction += Double.parseDouble(strTemp);
				  %>
                  <td width="48%" class="noBorder"> <div align="right"> <%=WI.getStrValue((String) vRetLoans.elementAt(j+1),"&nbsp;")%>&nbsp;</div></td>
                </tr>
                <% if (iRow == iTotRows){
						iRow = 1;
						break;
					}
				  }/// end for loop
				}//if (vRetLoans != null && vRetLoans.size() > 0) %>
              </table></td>
            <td colspan="2" class="noBorder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr> 
                  <td width="45%" height="18" valign="top" class="noBorder">&nbsp;</td>
                  <td width="55%" class="noBorder">&nbsp; </td>
                </tr>
              </table></td>
          </tr>
          <%}//if (vRetLoans != null && vRetLoans.size() > 0) %>
        </table>
        <%if(((String)vRetResult.elementAt(i+28)).equals("1")){%> <font color="#FF0000"><strong>&nbsp;Employee 
        on leave</strong></font> <%}%></td>
      <td valign="top" class="noBorder"><div align="right"> <%=WI.getStrValue(CommonUtil.formatFloat(dGrossPay,true),"")%>&nbsp;<br>
          <%=WI.getStrValue(CommonUtil.formatFloat(dTotalDeduction,true),"")%>&nbsp;<br>
          <%if (vRetResult.elementAt(i+6) != null && Double.parseDouble((String)vRetResult.elementAt(i+6)) != 0){					    
		dGrossPay += Double.parseDouble((String)vRetResult.elementAt(i+6));
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true);
	     %>
          <%=WI.getStrValue(strTemp,"")%>&nbsp; 
          <%}%>
        </div></td>
      <%
	  	dNetPay = dGrossPay - dTotalDeduction;
		dGrossPay = 0d;
		dTotalDeduction = 0d;
	  %>
      <td valign="top" class="noBorder"><div align="right"><br>
          <%=WI.getStrValue(CommonUtil.formatFloat(dNetPay,true)," ")%>&nbsp;</div></td>
    </tr>
    <tr> 
      <td valign="top" style="font-size: 9px">&nbsp;</td>
      <td height="15" valign="top" style="font-size: 9px">&nbsp;</td>
      <td colspan="3" valign="top"><hr size="1" color="#000000"></td>
    </tr>
    <%}// end if (vRetResult != null && vRetResult.size() > 0)
	} // end for(i = 0,iCount=1; i < vRetResult.size(); i += 30,++iCount){
	%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td valign="top" style="font-size: 9px">&nbsp;</td>
      <td colspan="3"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="184%" height="10" colspan="11">&nbsp;</td>
          </tr>
        </table></td>
  </table>
  <%}%>
  <%if (vRetResult != null && vRetResult.size() > 1 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF"><div align="center"><font><a href="javascript:PrintPg()"> 
          <img src="../../../images/print.gif" border="0"></a> <font size="1">click 
          to print</font></font></div></td>
    </tr>
  </table>
  <%}%>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>