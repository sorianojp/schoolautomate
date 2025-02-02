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
	TD.BorderTop {
	border-top: solid 1px #000000;
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }

</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<body onLoad="javascript:window.print();">>
<form name="form_" 	method="post" action="./payroll_summary_bystatus.jsp">
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME" %>
<%  WebInterface WI = new WebInterface(request);

	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;

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
	Vector vSummary = null;
	Vector vTemp = null;
	String strPayrollPeriod  = null;
	String[] astrPtFt = {"Part-Time","Full-Time","",""};
//	String strPeriodFr = null;
//	String strPeriodTo = null;
	boolean bolPageBreak = false;
	boolean bolSummary = false;
	
	double dPeriodRate     = 0d;
	double dGrossPay       = 0d;
	double dOtherDeduction = 0d;
	double dTotalDeduction = 0d;
	double dNetPay         = 0d;
	double dNoSalary       = 0d;
	double dTemp           = 0d;
	 int iTotRows = 3;/// THIS IS TO EASILY CONTROL THE NUMBER OF ROWS TO VIEW.
	int iNoSalary = 0;

	vRetResult = RptPay.searchByStatusExt(dbOP);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriod(dbOP, request, 4);
	
	if (vRetResult != null && vRetResult.size() > 0) {
	int i = 0; int k = 0; int iNumGrading = 0; int iCount = 0;
	int iMaxRecPerPage =10; 
	
	if (WI.fillTextValue("num_rec_page").length() > 0){
		iMaxRecPerPage = Integer.parseInt(WI.fillTextValue("num_rec_page"));
	}
	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	for (;iNumRec < vRetResult.size();){
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="24" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td height="24"><div align="center">&nbsp;</div></td>
      <td height="24"><font size="1">&nbsp;</font></td>
      <%
	 	strTemp = WI.fillTextValue("sal_period_index");		

		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 8) {
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
          strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		  //strPeriodFr = (String)vSalaryPeriod.elementAt(i + 1);
		  //strPeriodTo = (String)vSalaryPeriod.elementAt(i + 2);
          }
		}
		%>
      <td height="24"><div align="center"><strong><font size="1">
	  <%if (WI.fillTextValue("is_atm").equals("1")){%>
	    (ATM)
	  <%}%> 
	  Employees in the Payroll of <%=astrPtFt[Integer.parseInt(WI.getStrValue(WI.fillTextValue("pt_ft"),"2"))]%><br>
	  <%=WI.getStrValue(strPayrollPeriod,"")%>
	  </font></strong></div></td>
      <td height="24" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="5"><hr size="1" color="#666666"></td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="15%"><div align="center"><font size="1"><strong>ACCOUNT #</strong></font></div></td>
      <td width="69%"><div align="center"><font size="1"><strong>EMPLOYEE NAME</strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>TOTAL </strong></font></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>NET PAY</strong></font></div></td>
    </tr>
    <% 
		int iRow = 0;
//	if (vRetResult != null && vRetResult.size() > 0){
	  for(iCount=1; iNumRec < vRetResult.size(); iNumRec += 33,++iCount,++iIncr){
	  i = iNumRec;
		vRetLoans   = (Vector) vRetResult.elementAt(iNumRec+29);
		//vFacultySalary = (Vector) vRetResult.elementAt(i+32);
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;
		iRow = 1;
	  %>
    <tr> 
      <td valign="top" class="noBorder"><div align="right"><%=iIncr%>&nbsp;</div></td>
      <td height="36" valign="top" class="noBorder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1)," ")%><br> &nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+2)), (String)vRetResult.elementAt(i+3),
							((String)vRetResult.elementAt(i+4)), 4)%><br> &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5)," ")%></td>
      <td valign="top"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr valign="top"> 
            <td width="10%" height="15" class="noBorder">Basic</td>
            <td width="10%" class="noBorder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vRetResult.elementAt(i+8),true),"")%>&nbsp; 
              </div></td>
            <td width="10%" class="noBorder">&nbsp;Salary</td>
            <%  strTemp = CommonUtil.formatFloat(((String)vRetResult.elementAt(i+9)),true);
			    if(!((String)vRetResult.elementAt(i+28)).equals("1")){				
				dGrossPay += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				}				
			%>
            <td width="10%" class="noBorder"><div align="right"> <%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
            <%if (vRetResult.elementAt(i+24) != null && Double.parseDouble((String)vRetResult.elementAt(i+24)) > 0){
              strTemp = "COLA";
            }else{
              strTemp = ""; 
            }%>
            <td width="10%" class="noBorder"><%=strTemp%>&nbsp;</td>
            <%if (vRetResult.elementAt(i+24) != null){
				if (Double.parseDouble((String)vRetResult.elementAt(i+24)) > 0){
					dGrossPay += Double.parseDouble((String)vRetResult.elementAt(i+24));
					strTemp = CommonUtil.formatFloat(((String)vRetResult.elementAt(i+24)),true);
				}else{
					strTemp = "";
				}
			  }
			%>
            <td width="10%" class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
            <%if (vRetResult.elementAt(i+10) != null && Double.parseDouble((String)vRetResult.elementAt(i+10)) > 0){
				strTemp = "OVERTIME";
			}else{
				strTemp = "";
			}%>
            <td width="10%" class="noBorder"><%=WI.getStrValue(strTemp,"")%></td>
            <%if (vRetResult.elementAt(i+10) != null){				
				if (Double.parseDouble((String)vRetResult.elementAt(i+10)) > 0){
					dGrossPay += Double.parseDouble((String)vRetResult.elementAt(i+10));
					strTemp = CommonUtil.formatFloat(((String)vRetResult.elementAt(i+10)),true);
				}else{
					strTemp = "";
				}		
			  }
			%>
            <td width="10%" class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
            <%if (vRetResult.elementAt(i+27) != null && Double.parseDouble((String)vRetResult.elementAt(i+27)) > 0)
	              strTemp = "OVERLOAD / PART TIME"; 
              else
	              strTemp = "";
              %>
            <td width="10%" class="noBorder">&nbsp;<%=WI.getStrValue(strTemp,"")%></td>
            <%if (vRetResult.elementAt(i + 27) != null){				
				if (Double.parseDouble((String)vRetResult.elementAt(i+27)) > 0){
					dGrossPay += Double.parseDouble((String)vRetResult.elementAt(i+27));
					strTemp = CommonUtil.formatFloat(((String)vRetResult.elementAt(i+27)),true);
				}else{
					strTemp = "";
				}
			 }%>
            <td width="10%" class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"")%>&nbsp;</div></td>
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
            <td class="noBorder"><%=WI.getStrValue(strTemp,"")%>&nbsp;</td>
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
                <%			  
                   for(int j = 0; j < vRetLoans.size();j+=3,++iRow){%>
                <tr> 
                  <%  
				    strTemp = (String) vRetLoans.elementAt(j);
					strTemp = ConversionTable.replaceString(strTemp," ","");										
					  if (strTemp.length() > 5 && (vRetLoans.elementAt(j+2) != null) ){							
						strTemp = strTemp.substring(0,5);
					  }
					strTemp += WI.getStrValue((String)vRetLoans.elementAt(j+2),"&nbsp;");
				  %>
                  <td width="49%" valign="top" class="noBorder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
                  <%
				  	strTemp = ConversionTable.replaceString((String)vRetLoans.elementAt(j+1),",","");					
				    dTotalDeduction += Double.parseDouble(strTemp);
				  %>
                  <td width="51%" class="noBorder"> <div align="right"> <%=WI.getStrValue((String) vRetLoans.elementAt(j+1),"&nbsp;")%>&nbsp;</div></td>
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
                <tr> 
                  <td width="49%" height="18" valign="top" class="noBorder">&nbsp;</td>
                  <td width="51%" class="noBorder">&nbsp;</td>
                </tr>
              </table></td>
          </tr>
		  <%}//if (vRetLoans != null && vRetLoans.size() > 0)%>
        </table>
        <%if(((String)vRetResult.elementAt(i+28)).equals("1")){
			iNoSalary++;
			dNoSalary += Double.parseDouble((String)vRetResult.elementAt(i+9));
		%> 
		<font color="#FF0000"><strong>&nbsp;Employee on leave</strong></font>		
        <%}%> </td>
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
      <td colspan="3" valign="top"><hr size="1" color="#666666"></td>
    </tr>
    <%//}// end if (vRetResult != null && vRetResult.size() > 0)
	} // end for(i = 0,iCount=1; i < vRetResult.size(); i += 30,++iCount)
	%>
  </table>
    <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break only if it is not last page.
} //end for (iNumRec < vRetResult.size()
%>	
  <DIV style="page-break-before:always" >&nbsp;</DIV>
  <% 
  	vSummary = RptPay.summaryByStatus(dbOP);	
	if(vSummary != null && vSummary.size() > 0){
		vTemp = (Vector) vSummary.elementAt(22);
		dNetPay = 0d;
		dGrossPay = 0d;
		dTotalDeduction = 0d;
  %>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="30" colspan="7"><div align="center"><strong><font size="1"><%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></div></td>
    </tr>
    <tr> 
      <td height="18" colspan="7"><hr size="1" color="#666666"></td>
    </tr>
    <tr> 
      <td width="4%"><div align="center"></div></td>
      <td colspan="2"><div align="center"><font size="1">INCOME</font></div></td>
      <td width="6%"><font size="1">&nbsp;</font></td>
      <td width="28%"><div align="center"><font size="1">&nbsp;</font><font size="1">DEDUCTIONS</font></div></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td class="noBorder">&nbsp;</td>
      <td colspan="2" valign="top" class="noBorder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td width="62%" class="noBorder">Basic</td>
            <%strTemp = "";
				if (vSummary.elementAt(2) != null)
					strTemp = (String)vSummary.elementAt(2);			
			  %>
            <td width="38%" class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%> &nbsp;</div></td>
          </tr>
          <tr> 
            <td class="noBorder">Emp with no Salary</td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dNoSalary,true),"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <tr> 
            <td class="noBorder">Salary</td>
            <%strTemp = "";
			if (vSummary.elementAt(3) != null){
				strTemp = (String)vSummary.elementAt(3);
				dGrossPay += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
			}
		  %>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%strTemp = "";
		  	dTemp = 0d;
			if (vSummary.elementAt(18) != null){
				strTemp = (String)vSummary.elementAt(18);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">COLA</td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
          <%strTemp = "";
			  dTemp = 0d;
			if (vSummary.elementAt(4) != null){
				strTemp = (String)vSummary.elementAt(4);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">Overtime</td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
          <% strTemp = "";
			  dTemp = 0d;			
			if (vSummary.elementAt(15) != null){
				strTemp = (String)vSummary.elementAt(15);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">Night Differential</td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
          <%strTemp = "";
			  dTemp = 0d;						
			if (vSummary.elementAt(16) != null){
				strTemp = (String)vSummary.elementAt(16);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">Holiday Pay</td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
          <%strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(1) != null){
				strTemp = (String)vSummary.elementAt(1);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">Hon</td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
		  <%strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(0) != null){
				strTemp = (String)vSummary.elementAt(0);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dGrossPay += dTemp;
			}
		  %>
          <%if (dTemp != 0){%>
          <tr> 
            <td class="noBorder">&nbsp;Adjustment</td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>		  
        </table></td>
      <td>&nbsp;</td>
      <td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <% strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(14) != null){
				strTemp = (String)vSummary.elementAt(14);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dTotalDeduction += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td width="71%" class="noBorder">&nbsp;TxWitheld</td>
            <td width="29%" class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
          <% strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(8) != null){
				strTemp = (String)vSummary.elementAt(8);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dTotalDeduction += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">&nbsp;Pag-Ibig</td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
          <% strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(6) != null){
				strTemp = (String)vSummary.elementAt(6);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dTotalDeduction += dTemp;
			}
		    %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">&nbsp;SSS</td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
          <%strTemp = "";
			dTemp = 0d;
			if (vSummary.elementAt(7) != null){
				strTemp = (String)vSummary.elementAt(7);
				dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
				dTotalDeduction += dTemp;
			}
		  %>
          <%if (dTemp > 0){%>
          <tr> 
            <td class="noBorder">&nbsp;PhilHealth</td>
            <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
          </tr>
          <%}%>
          <%
		  if(vTemp!= null && vTemp.size() > 0){
			for(i = 0; i < vTemp.size(); i+=2){
			strTemp = (String)vTemp.elementAt(i+1);
			dTotalDeduction += Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
		%>
          <tr> 
            <td class="noBorder">&nbsp;<%=(String)vTemp.elementAt(i)%></td>
            <td class="noBorder"><div align="right"><%=strTemp%>&nbsp;</div></td>
          </tr>
          <%}// for(i = 0; i < vTemp.size(); i+=2)
		 }// if vTemp != null%>
        </table></td>
      <td>&nbsp;</td>
      <td valign="top"><font size="1">Total Emp : <%=iIncr-1%><br>
        No Salary: <%=iNoSalary%>&nbsp;&nbsp;&nbsp;&nbsp;Pay Slips: <%=(iIncr-1-iNoSalary)%></font></td>
    </tr>
    <tr> 
      <td class="noBorder">&nbsp;</td>
      <td width="15%" valign="top" class="noBorder"><div align="right">TOTAL&nbsp;&nbsp;</div></td>
      <td width="9%" valign="top" class="noBorder"><div align="right"><%=CommonUtil.formatFloat(dGrossPay,true)%>&nbsp;</div></td>
      <td>&nbsp;</td>
      <td valign="top" class="noBorder"><div align="right"><%=CommonUtil.formatFloat(dTotalDeduction,true)%>&nbsp;</div></td>
      <%dNetPay = dGrossPay - dTotalDeduction; %>
      <td width="8%" class="noBorder"><div align="right"><%=CommonUtil.formatFloat(dNetPay,true)%>&nbsp;</div></td>
      <td width="30%"><u><font size="1"><strong>NET PAY</strong></font></u></td>
    </tr>
  </table> 
	<%}//if(vSummary != null && vSummary.size() > 0)%>
  <%
  if(iNoSalary > 0){
	  dNoSalary = 0d;
  %>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="2"><hr size="1" color="#333333"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="5"><font size="1">List of Employees without pay slips</font></td>
    </tr>
    <tr> 
      <td width="7%"><font size="1">&nbsp;</font></td>
      <td width="27%"><font size="1">Name</font></td>
      <td width="27%">&nbsp;</td>
      <td width="13%"><div align="center"><font size="1">Basic</font></div></td>
      <td width="26%"><font size="1">&nbsp;</font></td>
    </tr>
    <%for(i=0, iIncr = 1; i < vRetResult.size(); i+=32){
		if(!((String)vRetResult.elementAt(i + 28)).equals("1")){
			continue;
		}
	%>
    <tr> 
      <td class="noBorder"><div align="right"><%=iIncr%>.&nbsp;</div></td>
      <td class="noBorder">&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+2)), (String)vRetResult.elementAt(i+3),
							((String)vRetResult.elementAt(i+4)), 4)%>&nbsp;#<%=(i/30) + 1%>&nbsp;pg<%=(i/30/10) + 1%></td>
	  <%if((String)vRetResult.elementAt(30) != null)
	  		strTemp = (String)vRetResult.elementAt(30);
		else
			strTemp = (String)vRetResult.elementAt(31);
	  %>
      <td class="noBorder"><%=strTemp%></td>
      <% 
		strTemp = "";					   
		dNoSalary += Double.parseDouble((String)vRetResult.elementAt(i+9));				
	    strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+9),true);
	%>
      <td class="noBorder"><div align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</div></td>
      <td>&nbsp;</td>
    </tr>
    <%++iIncr;
	}// for(i=0, iIncr = 1; i < vRetResult.size(); i+=30)%>
    <tr> 
      <td class="noBorder">&nbsp;</td>
      <td class="noBorder"><div align="right"></div></td>
      <td class="noBorder"><div align="right">Total: </div></td>
      <td class="BorderTop"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat(dNoSalary,true),"&nbsp;")%>&nbsp;</div></td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}// if i found an employee on leave sa list%>
  
<%} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>