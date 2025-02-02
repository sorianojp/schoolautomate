<%@ page language="java" import="utility.*,java.util.Vector, payroll.PRTaxReport, payroll.PRRemittance" 
				 buffer="16kb"%>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<title>Bureau of Internal Revenue - 1601-C</title>
<style>
	body{
		margin:0px;
		font-family:Arial, Helvetica, sans-serif;
		font-size:11px;
		color:#333333;
		font-weight:normal;
	}

	.container{
		border:4px #333333 solid;
	}
	
	.marginBottom{
		margin-bottom:2px;
	}
	.borderBottom{
		border-bottom:4px #333333 solid;
	}
	.borderBottomII{
		border-bottom:1px #333333 solid;
	}
	.borderRight{
		border-right:1px #333333 solid;
	}
	.borderRightBottom{
		border-bottom:1px #333333 solid;
		border-right:1px #333333 solid;
	}
	.borderLeft{
		border-left: 4px #333333 solid;
	}
	.textTitleHeader{
		font-family:Arial, Helvetica, sans-serif;
		font-size:21px;
		font-weight:bold;
		color:#333333;
	}
	td {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 11px;
	}
	
	.textbox_smallfont {
	background-color: #FDFDFD;
	border-style: inset;
	border-width: 1px;
	border-color: #194685;
	font-family: Arial, Verdana,  Helvetica, sans-serif;
	font-size: 11px;
}
	
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.
 
try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions","emp_prev_salary.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0){
			strErrMsg = "Image file extension is missing. Please contact admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"emp_prev_salary.jsp");
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

	PRTaxReport prEmpInfo = new PRTaxReport();
 	Vector vEditInfo = null;
 	Vector vEmployer = null;
	Vector vMonthValues = null;
 	String strEmpID = null;
	double dTemp = 0d;
	int iTemp = 0;
	double dSectionATotal = 0d;
	String strEmployerIndex = WI.fillTextValue("employer_index");
	String[] astrMonth = {"", "01", "02","03", "04", "05","06",
						"07",  "08", "09", "10", "11", "12"};	
						
	vMonthValues = prEmpInfo.getMonthlyReturnValue(dbOP, request, strEmployerIndex);	
	if(vMonthValues == null){
			strErrMsg = prEmpInfo.getErrMsg(); 
	} else {
		vEmployer = (Vector)vMonthValues.remove(0);
		if(vEmployer == null){
			strErrMsg = prEmpInfo.getErrMsg(); 
		} else {
			vEditInfo = prEmpInfo.operateOnEmployer1601c(dbOP, request, 4);
		}		
	}
%>
<body onload="javascript:window.print();">
<form name="form_">
<%if(vEmployer != null && vEmployer.size() > 0 && vEditInfo != null){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="marginBottom">   
		<tr>
			<td height="14" colspan="8" valign="top">(To be filled up by the BIR)</td>
		</tr>
		<tr>
			<td width="5%" height="14" ><img src="images/arrow2.png" width="6" height="6"/> DLN:</td>
			<td width="49%" >				<input name="textfield" type="text" id="textfield" style="width:345px; height:11px; text-align:left; border:1px #999999 solid"/>			</td>
				<td width="1%" ><img src="images/arrow2.png" width="6" height="6"/></td>
				<td width="5%" >PSOC:</td>
				<td width="17%" >					<input name="textfield" type="text" id="textfield" style="width:110px; height:11px; text-align:left; border:1px #999999 solid"/>			</td>
				<td width="1%" ><img src="images/arrow2.png" width="6" height="6"/></td>
				<td width="4%" >PSIC:</td>
				<td width="18%" ><input name="textfield" type="text" id="textfield" style="width:110px; height:11px; text-align:left; border:1px #999999 solid"/></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#CCCCCC" class="container">
    <tr>
      <td width="100%" height="70" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
          <tr>
            <td width="8%" height="66" bgcolor="#FFFFFF"><img src="images/bir_logo.png" width="64" height="48"/></td>
            <td width="24%" bgcolor="#FFFFFF"> Republika ng Pilipinas<br/>
              Kagawaran ng Pananalapi<br/>
              Kawanihan ng Rentas Internas </td>
            <td width="48%" bgcolor="#FFFFFF"><div align="center" class="textTitleHeader"> Monthly Remittance Return<br/>
              of Income Taxes Withheld<br/>
              on Compensation</div></td>
            <td width="20%" bgcolor="#FFFFFF"><div > <span>BIR Form No.</span><br/>
                    <span class="textTitleHeader">1601-C</span><br/>
              September 2001 (ENCS) </div></td>
          </tr>
      </table></td>
    </tr>
    <tr>
      <td height="18" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
          <tr>
            <td height="14" bgcolor="#FFFFFF"><div > Fill in all applicable spaces. Mark all appropriate boxes with an &quot;X&quot; </div></td>
          </tr>
      </table></td>
    </tr>
    <tr>
      <td valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
          <tr>
            <td width="14%" height="14"><strong>1</strong> For the month</td>
            <td colspan="2" class="borderRight">&nbsp;</td>
            <td colspan="6" class="borderRight"><strong>2</strong> Amended Return?</td>
            <td colspan="2" class="borderRight"><strong>3</strong> No. of sheets attached</td>
            <td colspan="6" ><strong>4</strong> Any Taxes Withheld?</td>
          </tr>
          <tr>
            <td height="25" valign="top">&nbsp;&nbsp;&nbsp;(MM/YYYY)</td>
            <td width="1%" bgcolor="#CCCCCC" img="img"/bg1.gif><img src="images/arrow1.png" width="6" height="6"/></td>
            <%
						strTemp = WI.fillTextValue("month_of");
						iTemp = Integer.parseInt(strTemp) + 1;
						strTemp = Integer.toString(iTemp);								
						if(strTemp.length() == 1)
							strTemp = "0"+strTemp;
					%>
            <td width="20%" class="borderRight">
						<input name="month_" type="text" value="<%=strTemp%>" maxlength="2" size="3" class="textbox_smallfont"
						readonly style="text-align:center;"/>
                <%
							strTemp = WI.fillTextValue("year_of");
						%>
                <input name="year_" type="text" value="<%=strTemp%>" maxlength="4" size="5" class="textbox_smallfont"
						readonly style="text-align:center;"/></td>
            <td width="3%" >&nbsp;</td>
            <td width="2%" ><img src="images/arrow1.png" width="6" height="6"/></td>
            <%
						strTemp = (String)vEditInfo.elementAt(3);
						strTemp = WI.getStrValue(strTemp, "0");
						if(strTemp.equals("1"))
								strTemp2 = "images/x_select.JPG";
							else
								strTemp2 = "images/x_blank.JPG";
						%>
            <td width="3%" ><img src="<%=strTemp2%>" width="15" height="18" border="0" /></td>
            <td width="5%" >Yes</td>
            <%
							if(strTemp.equals("0"))
								strTemp2 = "images/x_select.JPG";
							else
								strTemp2 = "images/x_blank.JPG";
						%>
            <td width="3%"><img src="<%=strTemp2%>" width="15" height="18" border="0" /></td>
            <td width="6%" class="borderRight">No </td>
            <td width="12%">&nbsp;</td>
            <%
								strTemp = (String)vEditInfo.elementAt(4);
						%>
            <td width="7%" class="borderRight"><input name="addl_sheets" type="text" class="textbox_smallfont" onfocus="style.backgroundColor='#D3EBFF'"
						onblur="AllowOnlyFloat('form_','addl_sheets');style.backgroundColor='white'"
						onkeyup="AllowOnlyFloat('form_','addl_sheets');" style="text-align : right"
						value="<%=WI.getStrValue(strTemp,"0")%>" size="4" maxlength="3"/></td>
            <td width="4%">&nbsp;</td>
            <td width="1%"><img src="images/arrow1.png" width="6" height="6"/></td>
            <%
						strTemp = (String)vEditInfo.elementAt(5);						
						strTemp = WI.getStrValue(strTemp, "0");
						if(strTemp.equals("1"))
								strTemp2 = "images/x_select.JPG";
							else
								strTemp2 = "images/x_blank.JPG";
						%>
            <td width="3%"><img src="<%=strTemp2%>" width="15" height="18" border="0" /></td>
            <td width="7%">Yes</td>
            <%																
						if(strTemp.equals("0"))
								strTemp2 = "images/x_select.JPG";
							else
								strTemp2 = "images/x_blank.JPG";
						%>
            <td width="3%"><img src="<%=strTemp2%>" width="15" height="18" border="0" /></td>
            <td width="6%">No</td>
          </tr>
      </table></td>
    </tr>
    <tr>
      <td height="18" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
          <tr background="images/bg1.gif">
            <td width="13%" height="14" bgcolor="#CCCCCC"><strong>Part I</strong></td>
            <td width="74%" align="center" bgcolor="#CCCCCC"><strong>Background Information</strong></td>
            <td width="13%" align="center" bgcolor="#CCCCCC">&nbsp;</td>
          </tr>
      </table></td>
    </tr>
    <tr>
      <td valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#CCCCCC" class="borderBottom">
          <tr>
            <td valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottomII">
                <tr>
                  <td height="12" nowrap="nowrap" ><strong>5</strong></td>
                  <td height="12" >TIN</td>
                  <td width="20%" rowspan="2" class="thinborderRIGHT" >
									<table width="94%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
										<tr>
										<%
											if(vEmployer != null && vEmployer.size() > 0)
												strTemp = (String)vEmployer.elementAt(7);
							
											strTemp = WI.getStrValue(strTemp);
										%>			
											<td align="center" style="font-size:12px"><%=strTemp%></td>
											</tr>
									</table>			
									</td>
                  <td nowrap="nowrap"><strong>6</strong> RDO Code</td>
                  <td>&nbsp;</td>     
                  <td width="11%" rowspan="2" class="thinborderALL">
                    <table width="94%" height="20" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborderALL">
										<tr>
										<%
											if(vEmployer != null && vEmployer.size() > 0)
												strTemp = (String)vEmployer.elementAt(13);
							
											strTemp = WI.getStrValue(strTemp);
										%>			
											<td align="center" style="font-size:12px"><%=strTemp%></td>
											</tr>
									</table>
                  </td>
                  <td width="14%" rowspan="2" valign="top" nowrap="nowrap"><strong>7</strong> Line of Business/<br/>
                    Occupation</td>
                  <td width="2%" >&nbsp;</td>
                  <%
										strTemp = (String)vEditInfo.elementAt(7);
									%>
                  <td width="34%" rowspan="2">
									<table width="99%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
										<tr>
											<td class="thinborderALL" height="20"><%=WI.getStrValue(strTemp)%></td>
										</tr>
                  </table></td>
                </tr>
                <tr>
                  <td width="4%" height="12" align="right" ><img src="images/arrow1.png" width="6" height="6"/></td>
                  <td width="3%" align="right" >&nbsp;</td>
                  <td width="10%" height="12" align="right" ><img src="images/arrow1.png" width="6" height="6"/></td>
                  <td width="2%" align="right" >&nbsp;</td>
                  <td width="2%" align="right" ><img src="images/arrow1.png" width="6" height="6"/></td>
                </tr>
            </table></td>
          </tr>
          <tr>
            <td valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottomII">
                <tr>
                  <td height="18" colspan="3" class="borderRight"><strong>8</strong> Withholding Agent's Name (Last Name, First Name, Middle Name for Individuals)/(Registered Name for Non-Individual)</td>
                  <td colspan="2" ><strong>9</strong> Telephone Number</td>
                </tr>
                <tr>
                  <td height="22" width="4%" align="right" class="thinborderBOTTOM" ><img src="images/arrow1.png" width="6" height="6"/></td>
                  <td width="2%" align="right" class="thinborderBOTTOM" >&nbsp;</td>
                  <%
									if(vEmployer != null && vEmployer.size() > 0)											
										strTemp = (String)vEmployer.elementAt(12);
									else
										strTemp = WI.fillTextValue("agent_name");
								%>
                  <td width="78%" class="thinborderBOTTOMRIGHT">
									<table width="99%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
										<tr>
											<td class="thinborderALL" height="20"><%=strTemp%></td>
										</tr>
                  </table>
									</td>
                  <%
									if(vEmployer != null && vEmployer.size() > 0)											
										strTemp = (String)vEmployer.elementAt(5);
									else
										strTemp = WI.fillTextValue("tel_no");
								%>
                  <td colspan="2" class="thinborderBOTTOM"><table width="94%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
                    <tr>
                      <td class="thinborderALL" height="20"><%=WI.getStrValue(strTemp)%></td>
                    </tr>
                  </table></td>
                </tr>
                <tr>
                  <td height="18" colspan="3" class="borderRight"><strong>10</strong> Registered Address</td>
                  <td colspan="2" ><strong>11</strong> Zip Code</td>
                </tr>
                <tr>
                  <td height="22" width="4%" align="right" class="thinborderBOTTOM" ><img src="images/arrow1.png" width="6" height="6"/></td>
                  <td width="2%" align="right" class="thinborderBOTTOM" >&nbsp;</td>
                  <%
									if(vEmployer != null && vEmployer.size() > 0)											
											strTemp = (String)vEmployer.elementAt(3);
									else
										strTemp = WI.fillTextValue("agent_address");
								%>
                  <td width="78%" class="thinborderBOTTOMRIGHT">
									<table width="99%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
										<tr>
											<td class="thinborderALL" height="20"><%=strTemp%></td>
										</tr>
                  </table></td>
                  <td width="2%" align="right" class="thinborderBOTTOM" ><img src="images/arrow1.png" width="6" height="6"/></td>
                  <%
									if(vEmployer != null && vEmployer.size() > 0)											
										strTemp = (String)vEmployer.elementAt(4);
									else
										strTemp = WI.fillTextValue("zip_code");
								%>
                  <td width="14%" class="thinborderBOTTOM"><table width="94%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
                    <tr>
                      <td class="thinborderALL" height="20"><%=WI.getStrValue(strTemp)%></td>
                    </tr>
                  </table></td>
                </tr>
                <tr>
                  <td colspan="3" class="borderRight"><table width="100%" border="0" cellpadding="0" cellspacing="0">
                      <tr>
                        <td colspan="6" rowspan="2" valign="top" class="borderRight"><strong>12</strong> Category of Withholding Agent</td>
                        <td colspan="6" height="12"><strong>13</strong> Are there payees availing tax relief under Special law</td>
                      </tr>
                      <tr>
                        <td height="12">&nbsp;</td>
                        <td colspan="4">or International Tax Treaty?</td>
                        <%
												strTemp = (String)vEditInfo.elementAt(9);
												%>
                        <td width="34%" rowspan="2">
												<table width="99%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
													<tr>
														<td class="thinborderALL" height="23"><%=WI.getStrValue(strTemp)%></td>
													</tr>
												</table>
												</td>
                      </tr>
                      <tr>
                        <td width="3%" height="18" align="right" ><img src="images/arrow1.png" width="6" height="6"/></td>
                        <td width="1%" >&nbsp;</td>
                        <%
									if(vEmployer != null && vEmployer.size() > 0){
										strTemp = (String)vEmployer.elementAt(2);
										if(strTemp.equals("1"))
											strTemp = "1";
										else
											strTemp = "0";
										
									}else
										strTemp = WI.fillTextValue("is_private");
									
								strTemp = WI.getStrValue(strTemp, "0");
								if(strTemp.equals("1"))
									strTemp2 = "images/x_select.JPG";
								else
									strTemp2 = "images/x_blank.JPG";								
								%>
                        <td width="3%" ><img src="<%=strTemp2%>" width="15" height="18" border="0" /></td>
                        <td width="7%" >Private</td>
                        <%
								if(strTemp.equals("0"))
									strTemp2 = "images/x_select.JPG";
								else
									strTemp2 = "images/x_blank.JPG";
								%>
                        <td width="4%" ><img src="<%=strTemp2%>" width="15" height="18" border="0" /></td>
                        <td width="14%" class="borderRight">Government</td>
                        <%
										strTemp = (String)vEditInfo.elementAt(8);
												
											strTemp = WI.getStrValue(strTemp, "0");
										if(strTemp.equals("1"))
											strTemp2 = "images/x_select.JPG";
										else
											strTemp2 = "images/x_blank.JPG";	
										%>
                        <td width="3%" ><img src="<%=strTemp2%>" width="15" height="13" border="0" /></td>
                        <td width="8%" >Yes</td>
                        <%
								if(strTemp.equals("0"))
									strTemp2 = "images/x_select.JPG";
								else
									strTemp2 = "images/x_blank.JPG";	
								%>
                        <td width="3%" ><img src="<%=strTemp2%>" width="15" height="13" border="0" /></td>
                        <td width="6%" >No</td>
                        <td width="14%" >If yes, specify</td>
                      </tr>
                  </table></td>
                  <td colspan="2" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
                      <tr >
                        <td colspan="2" height="20"><strong>14</strong> ATC </td>
                      </tr>
                      <tr>
                        <td width="15%" align="right" height="2" ><img src="images/arrow1.png" width="6" height="6"/></td>
                        <%
												strTemp = (String)vEditInfo.elementAt(10);
												%>
                        <td width="85%"><table width="94%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
                    <tr>
                      <td class="thinborderALL" height="20"><%=WI.getStrValue(strTemp)%></td>
                    </tr>
                  </table></td>
                      </tr>
                  </table></td>
                </tr>
            </table></td>
          </tr>
      </table></td>
    </tr>
    <tr>
      <td height="19" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
          <tr>
            <td width="13%" height="15" ><strong>Part II</strong></td>
            <td width="74%" align="center"><img src="images/arrow1.png" width="6" height="6"/><strong> Computation of Tax</strong></td>
            <td width="13%" >&nbsp;</td>
          </tr>
      </table></td>
    </tr>
    <tr>
      <td valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
          <tr>
            <td height="17" colspan="2" align="center"><strong>Particulars</strong></td>
            <td colspan="2" align="center"><strong>Amount of Compensation</strong></td>
            <td colspan="2" align="center"><strong>Tax Due</strong></td>
          </tr>
          <tr>
            <td height="17" colspan="2" ><strong>15</strong> Total amount of Compensation</td>
            <td align="right"><strong>15</strong></td>
            <%
							strTemp = (String)vEditInfo.elementAt(11);							
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
            <td colspan="2">
							<table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
								<tr>
									<td height="20" align="right" class="thinborderALL"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
								</tr>
               </table>            </td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td height="17" colspan="2" ><strong>16</strong> Less: Non Taxable Compensation</td>
            <td align="right" ><strong>16</strong></td>
            <%
							strTemp = (String)vEditInfo.elementAt(12);
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";								
						%>
            <td colspan="2" > 
							<table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
								<tr>
									<td height="20" align="right" class="thinborderALL"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
								</tr>
               </table>						</td>
            <td >&nbsp;</td>
          </tr>
          <tr>
            <td height="17" colspan="2" ><strong>17</strong> Taxable Compensation</td>
            <td align="right" ><strong>17</strong></td>
            <%
							strTemp = (String)vEditInfo.elementAt(13);								
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
            <td colspan="2" ><table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
								<tr>
									<td height="20" align="right" class="thinborderALL"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
								</tr>
               </table>						</td>
            <td >&nbsp;</td>
          </tr>
          <tr>
            <td height="17" colspan="4" ><strong>18</strong> Tax Required to be Withheld</td>
            <td align="right"><strong>18&nbsp;</strong></td>
            <%
							strTemp = (String)vEditInfo.elementAt(14);
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
            <td><table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
              <tr>
                <td height="20" align="right" class="thinborderALL"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
              </tr>
            </table></td>
          </tr>
          <tr>
            <td height="17" colspan="4" ><strong>19</strong> Add/Less: Adjustment (from Item 25 of Section A)</td>
            <td align="right" ><strong>19&nbsp;</strong></td>
            <%
							strTemp = (String)vEditInfo.elementAt(15);
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
            <td><table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
              <tr>
                <td height="20" align="right" class="thinborderALL"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
              </tr>
            </table></td>
          </tr>
          <tr>
            <td height="17" colspan="4" ><strong>20</strong> Tax Required to be Withheld for Remittance</td>
            <td align="right" ><strong>20&nbsp;</strong></td>
            <%
							strTemp = (String)vEditInfo.elementAt(16);
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
            <td><table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
              <tr>
                <td height="20" align="right" class="thinborderALL"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
              </tr>
            </table></td>
          </tr>
          <tr>
            <td height="17" colspan="4" ><strong>21</strong> Less: Tax Previously Remitted in Return Previously Filed, if this is an ammended return</td>
            <td align="right" ><strong>21&nbsp;</strong></td>
            <%
							strTemp = (String)vEditInfo.elementAt(17);
							
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
            <td><table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
              <tr>
                <td height="20" align="right" class="thinborderALL"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
              </tr>
            </table></td>
          </tr>
          <tr>
            <td height="17" colspan="4" ><strong>22</strong> Tax Still Due/(Overremittance)</td>
            <td align="right" ><strong>22&nbsp;</strong></td>
            <%
							strTemp = (String)vEditInfo.elementAt(18);								
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
            <td><table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
              <tr>
                <td height="20" align="right" class="thinborderALL"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
              </tr>
            </table></td>
          </tr>
          <tr>
            <td height="14" colspan="6" ><strong>23</strong> Add: Penalties</td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td colspan="3" ><table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                  <td width="4%">&nbsp;</td>
                  <td colspan="2" align="center"><strong>Surcharge</strong></td>
                  <td colspan="2" align="center"><strong>Interest</strong></td>
                  <td colspan="2" align="center"><strong>Compromise</strong></td>
                </tr>
                <tr>
                  <td>&nbsp;</td>
                  <td width="7%"><strong>23A</strong></td>
                  <%
									strTemp = (String)vEditInfo.elementAt(19);

								dTemp = 0d;
								if(strTemp.length() > 0){
									dTemp = Double.parseDouble(strTemp);
								}
								if(dTemp <= 0d)
									strTemp = "";
								%>
                  <td width="27%"><input name="surcharge" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','surcharge');computePenalty();" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','surcharge');"
							style="text-align:right"/></td>
                  <td width="7%"><strong>23B</strong></td>
                  <%
									strTemp = (String)vEditInfo.elementAt(20);
								
								dTemp = 0d;
								if(strTemp.length() > 0){
									dTemp = Double.parseDouble(strTemp);
								}
								if(dTemp <= 0d)
									strTemp = "";
								%>
                  <td width="25%"><input name="interest" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','interest');computePenalty();" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','interest');"
							style="text-align:right" /></td>
                  <td width="6%"><strong>23C</strong></td>
                  <%
									strTemp = (String)vEditInfo.elementAt(21);

								dTemp = 0d;
								if(strTemp.length() > 0){
									dTemp = Double.parseDouble(strTemp);
								}
								if(dTemp <= 0d)
									strTemp = "";
								%>
                  <td width="24%"><input name="compromise" type="text" value="<%=strTemp%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','compromise');computePenalty();" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','compromise');"
							style="text-align:right"/></td>
                </tr>
            </table></td>
            <td height="14" align="right" ><strong>23D&nbsp;</strong></td>
            <%
								strTemp = (String)vEditInfo.elementAt(22);
							
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
            <td valign="bottom"><table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
              <tr>
                <td height="20" align="right" class="thinborderALL"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
              </tr>
            </table></td>
          </tr>
          <tr>
            <td height="17" colspan="4" ><strong>24</strong> Total Amount Still Due/(Overremittance) </td>
            <td align="right"><strong>24&nbsp;</strong></td>
            <%
								strTemp = (String)vEditInfo.elementAt(23);
								
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
            <td><table width="95%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
              <tr>
                <td height="20" align="right" class="thinborderALL"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
              </tr>
            </table></td>
          </tr>
          <tr>
            <td width="2%" height="0"></td>
            <td width="45%"></td>
            <td width="4%" ></td>
            <td width="25%"></td>
            <td width="4%"></td>
            <td width="20%"></td>
          </tr>
      </table></td>
    </tr>
    <tr>
      <td height="18" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
          <tr>
            <td width="13%" height="14" bgcolor="#CCCCCC"><strong>Section A</strong></td>
            <td width="74%" align="center" bgcolor="#CCCCCC"><strong>Adjustment of Taxes Withheld on Compensation For Previous Months</strong></td>
            <td width="13%" align="center" bgcolor="#CCCCCC">&nbsp;</td>
          </tr>
      </table></td>
    </tr>
    <tr>
      <td valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom" bgcolor="#FFFFFF">
          <tr>
            <td height="57" align="center" class="borderRightBottom"> Previous Month(s)<br/>
              (1)<br/>
              (MM/YYYY)</td>
            <td align="center" class="borderRightBottom"> Date Paid<br/>
              (2)<br/>
              (MM/DD/YYYY)</td>
            <td width="25%" align="center" class="borderRightBottom"> Bank Validation/<br/>
              ROR No.<br/>
              (3)</td>
            <td width="25%" align="center" class="borderBottomII"> Bank Code<br/>
              (4)<br/>
              &nbsp;</td>
          </tr>
          <tr>
						<%
								strTemp = (String)vEditInfo.elementAt(37);
								strTemp2 = (String)vEditInfo.elementAt(38);
								
								if(strTemp != null && strTemp.length() > 0 && 
									  strTemp2 != null && strTemp2.length() > 0){									
										strTemp = astrMonth[Integer.parseInt(strTemp)];										
										strTemp += "/"+strTemp2;
								}else{
									strTemp =  "";
								}
 						%>						
            <td height="22" align="center" class="borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(43);
						%>
            <td align="center" class="borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(46);
						%>
            <td align="center" class="borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(49);
						%>
            <td align="center" class="borderBottomII"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
          </tr>
          <tr>
<%
								strTemp = (String)vEditInfo.elementAt(39);
								strTemp2 = (String)vEditInfo.elementAt(40);
								
								if(strTemp != null && strTemp.length() > 0 && 
									  strTemp2 != null && strTemp2.length() > 0){									
										strTemp = astrMonth[Integer.parseInt(strTemp)];										
										strTemp += "/"+strTemp2;
								}else{
									strTemp =  "";
								}
 						%>						
            <td height="22" align="center" class="borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(44);
						%>
            <td align="center" class="borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(47);
						%>
            <td align="center" class="borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(50);
						%>
            <td align="center" class="borderBottomII"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
          </tr>
          <tr>
<%
								strTemp = (String)vEditInfo.elementAt(41);
								strTemp2 = (String)vEditInfo.elementAt(42);
								
								if(strTemp != null && strTemp.length() > 0 && 
									  strTemp2 != null && strTemp2.length() > 0){									
										strTemp = astrMonth[Integer.parseInt(strTemp)];										
										strTemp += "/"+strTemp2;
								}else{
									strTemp =  "";
								}
 						%>						
            <td height="22" align="center" class="borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(45);
						%>
            <td align="center" class="borderRight"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(48);
						%>
            <td align="center" class="borderRight"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(51);
						%>						
            <td align="center"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
          </tr>
      </table></td>
    </tr>
    <tr>
      <td height="19" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
          <tr>
            <td width="21%" height="14" bgcolor="#CCCCCC"><strong>Section A (Continuation)</strong></td>
            <td width="66%" align="center" bgcolor="#CCCCCC">&nbsp;</td>
            <td width="13%" align="center" bgcolor="#CCCCCC">&nbsp;</td>
          </tr>
      </table></td>
    </tr>
    <tr>
      <td valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom" bgcolor="#FFFFFF">
          <tr>
            <td width="25%" rowspan="2" align="center" class="borderRightBottom"> Tax Paid (Excluding Penalties)<br/>
              for the month<br/>
              (5)</td>
            <td colspan="2" rowspan="2" align="center" class="borderRightBottom"> Should Be Tax Due<br/>
              for the Month<br/>
              (6)</td>
            <td height="23" colspan="2" align="center" class="borderBottomII">Adjustment (7)</td>
          </tr>
          <tr>
            <td width="24%" height="29" align="center" class="borderRightBottom">From Current Year <br/>
              (7a)</td>
            <td width="26%" align="center" class="borderBottomII"> From Year - End Adjustment of the<br/>
              Immediately Preceeding Year (7a)</td>
          </tr>
          <tr>
						<%
							strTemp = (String)vEditInfo.elementAt(52);
						%>					
            <td height="22" align="center" class="borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(55);
						%>					
            <td colspan="2" align="center" class="borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(58);
							strTemp = WI.getStrValue(strTemp);	
							if(strTemp.length() > 0)	
								dSectionATotal += Double.parseDouble(strTemp);							
						%>					
            <td align="center" class="borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(61);
							strTemp = WI.getStrValue(strTemp);	
							if(strTemp.length() > 0)	
								dSectionATotal += Double.parseDouble(strTemp);							
						%>					
            <td align="center" class="borderBottomII"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
          </tr>
          <tr>
						<%
							strTemp = (String)vEditInfo.elementAt(53);
						%>					
            <td height="22" align="center" class="borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(56);
						%>					
            <td colspan="2" align="center" class="borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(59);
							strTemp = WI.getStrValue(strTemp);	
							if(strTemp.length() > 0)	
								dSectionATotal += Double.parseDouble(strTemp);							
						%>					
            <td align="center" class="borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(62);
							strTemp = WI.getStrValue(strTemp);	
							if(strTemp.length() > 0)	
								dSectionATotal += Double.parseDouble(strTemp);							
						%>					
            <td align="center" class="borderBottomII"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
          </tr>
          <tr>
						<%
							strTemp = (String)vEditInfo.elementAt(54);
						%>						
            <td height="22" align="center" class=" borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(57);
						%>	
            <td colspan="2" align="center" class=" borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(60);
							strTemp = WI.getStrValue(strTemp);	
							if(strTemp.length() > 0)	
								dSectionATotal += Double.parseDouble(strTemp);							
						%>	
            <td align="center" class=" borderRightBottom"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
						<%
							strTemp = (String)vEditInfo.elementAt(63);
							strTemp = WI.getStrValue(strTemp);	
							if(strTemp.length() > 0)	
								dSectionATotal += Double.parseDouble(strTemp);							
						%>	
						<td align="center" class="borderBottomII"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
          </tr>
          <tr>
            <td height="22" colspan="2" ><strong>25</strong> Total (7a plus 7b) (To Item 19)</td>
						<%
							strTemp = CommonUtil.formatFloat(dSectionATotal, 2);
						%>
            <td colspan="3" align="center"><span class="borderBottomII"><%=WI.getStrValue(strTemp, "&nbsp;")%></span></td>
          </tr>
          <tr>
            <td height="0"></td>
            <td width="17%"></td>
            <td></td>
            <td></td>
            <td></td>
          </tr>
          <tr>
            <td height="1"></td>
            <td></td>
            <td width="8%"></td>
            <td></td>
            <td></td>
          </tr>
      </table></td>
    </tr>
    <tr>
      <td valign="top">
			 <table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom" bgcolor="white">
          <tr>
            <td colspan="6"><pre style="font-family:Arial, Verdana, Helvetica, sans-serif;font-size:10px;">
            I declare, under the penalties of perjury, that this return has been made in good faith, verified me, and to the best of my knowledge and belief, 
 is true and correct, pursuant to the provisions of the National Internal Revenue Code, as amended, and the regulations issued under authority thereof.</pre></td>
          </tr>
          <tr>
            <%
								strTemp = (String)vEditInfo.elementAt(24);
						%>
            <td width="10%" height="22" align="right"><strong>26</strong></td>
            <td width="30%" align="center" class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue(strTemp)%></td>
            <td width="10%" align="center">&nbsp;</td>
            <%
								strTemp = (String)vEditInfo.elementAt(25);
						%>
            <td width="11%" align="right"><strong>27</strong></td>
            <td width="28%" align="center" class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue(strTemp)%></td>
            <td width="11%" align="center">&nbsp;</td>
          </tr>
          <tr>
            <td height="23" colspan="3" align="center"> Signature over printed name of Taxpayer/<br/>
              Authorized Representative</td>
            <td colspan="3" align="center">Title/Position of Signatory</td>
          </tr>
          <tr>
            <%
								strTemp = (String)vEditInfo.elementAt(26);
						%>
            <td height="23" align="center">&nbsp;</td>
            <td align="center" class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue(strTemp)%></td>
            <td align="center">&nbsp;</td>
            <%
								strTemp = (String)vEditInfo.elementAt(27);
						%>
            <td height="23" align="center">&nbsp;</td>
            <td height="23" align="center" class="thinborderBOTTOM">&nbsp;<%=WI.getStrValue(strTemp)%></td>
            <td height="23" align="center">&nbsp;</td>
          </tr>
          <tr>
            <td height="20" colspan="3" align="center" valign="top">TIN of Tax Agent (If applicable)</td>
            <td height="20" colspan="3" align="center" valign="top">Tax Agent Accreditation No. (If applicable)</td>
          </tr>
      </table></td>
    </tr>
    <tr>
      <td height="19" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
          <tr>
            <td width="10%" height="15" bgcolor="#CCCCCC"><strong>Part III</strong></td>
            <td width="77%" align="center" bgcolor="#CCCCCC"><strong>Details of Payment</strong></td>
            <td width="13%" align="center" bgcolor="#CCCCCC">&nbsp;</td>
          </tr>
      </table></td>
    </tr>
    <tr>
      <td valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="borderBottom">
          <tr>
            <td width="15%" height="27" rowspan="2" align="center" valign="bottom" class="borderRightBottom"><strong >Particulars</strong></td>
            <td colspan="2" rowspan="2" align="center" class="borderRightBottom"><strong>Drawee Bank/<br/>
              Agency</strong></td>
            <td colspan="2" rowspan="2" align="center" valign="bottom" class="borderRightBottom"><strong>Number</strong></td>
            <td align="center">&nbsp;</td>
            <td width="6%" align="center" class="borderBottomII">&nbsp;</td>
            <td align="center" class="borderBottomII"><strong>Date</strong></td>
            <td align="center" class="borderRightBottom">&nbsp;</td>
            <td colspan="2" rowspan="2" align="center" valign="bottom" class="borderBottomII"><strong >Amount</strong></td>
            <td width="18%" rowspan="5" align="center" valign="top" class="borderLeft" bgcolor="#FFFFFF" >Stamp of Receiving<br/>
              Office and Date of<br/>
              Receipt</td>
          </tr>
          <tr>
            <td align="center" class="borderRightBottom">&nbsp;</td>
            <td align="center" class="borderRightBottom"><strong>MM</strong></td>
            <td width="6%" align="center" class="borderRightBottom"><strong>DD</strong></td>
            <td width="7%" align="center" class="borderRightBottom"><strong>YYYY</strong></td>
          </tr>
          <tr>
            <td height="28" valign="top"><strong>28</strong> Cash/Bank<br/>
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Debit Memo</td>
            <td height="28" colspan="2" >&nbsp;</td>
            <td height="28" colspan="2" >&nbsp;</td>
            <td height="28" colspan="4" >&nbsp;</td>
            <td width="3%" height="28" align="right" ><strong>28</strong><br/>
                <img src="images/arrow1.png"/></td>
            <%
								strTemp = (String)vEditInfo.elementAt(28);
								
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
            <td width="13%"><input name="cash_amt" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','cash_amt');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','cash_amt');"
							style="text-align:right" /></td>
          </tr>
          <tr>
            <td height="26" ><strong>29</strong> Check</td>
            <td width="3%" height="26" align="right" ><strong>29A</strong><br/>
                <img src="images/arrow1.png"/></td>
            <%
								strTemp = (String)vEditInfo.elementAt(29);
						%>
            <td width="13%" height="26" ><input name="check_drawee" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'; "/></td>
            <td width="3%" height="26" align="right" ><strong>29B</strong><br/>
                <img src="images/arrow1.png"/></td>
            <%
								strTemp = (String)vEditInfo.elementAt(30);
						%>
            <td width="10%" ><input name="check_no" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'; "/></td>
            <td width="3%" height="26" align="right" ><strong>29C</strong><br/>
                <img src="images/arrow1.png"/></td>
            <%
								strTemp = (String)vEditInfo.elementAt(31);
						%>
            <td height="26" colspan="3" ><input name="check_date" type="text" size="12" maxlength="12" readonly="readonly" value="<%=WI.getStrValue(strTemp)%>" class="textbox_smallfont"
	 					 onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
              <a href="javascript:show_calendar('form_.check_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"></a></td>
            <td height="26" align="right" ><strong>29D</strong><br/>
                <img src="images/arrow1.png"/></td>
            <%
								strTemp = (String)vEditInfo.elementAt(32);
							
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
            <td height="26" ><input name="check_amt" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','check_amt');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','check_amt');"
							style="text-align:right" /></td>
          </tr>
          <tr>
            <td height="22" ><strong>30</strong> Others</td>
            <td height="22" align="right" ><strong>30A</strong><br/>
                <img src="images/arrow1.png"/></td>
            <%
								strTemp = (String)vEditInfo.elementAt(33);
						%>
            <td height="22" ><input name="other_drawee" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white';"/></td>
            <%
								strTemp = (String)vEditInfo.elementAt(34);
						%>
            <td height="22" align="right" ><strong>30B</strong><br/>
                <img src="images/arrow1.png"/></td>
            <td height="22" ><input name="other_no" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'"  onblur="style.backgroundColor='white'; "/></td>
            <td height="22" align="right" ><strong>30C</strong><br/>
                <img src="images/arrow1.png"/></td>
            <%
								strTemp = (String)vEditInfo.elementAt(35);
						%>
            <td height="22" colspan="3" ><input name="other_date" type="text" size="12" maxlength="12" readonly="readonly" value="<%=WI.getStrValue(strTemp)%>" class="textbox_smallfont"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
              <a href="javascript:show_calendar('form_.other_date');" title="Click to select date" onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;"></a></td>
            <td height="22" align="right" ><strong>29D</strong><br/>
                <img src="images/arrow1.png"/></td>
            <%
								strTemp = (String)vEditInfo.elementAt(36);
							
							dTemp = 0d;
							if(strTemp.length() > 0){
								dTemp = Double.parseDouble(strTemp);
							}
							if(dTemp <= 0d)
								strTemp = "";
						%>
            <td height="22" ><input name="other_amt" type="text" value="<%=WI.getStrValue(strTemp)%>" maxlength="12" size="14" class="textbox_smallfont"
							onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','other_amt');" 
							onblur="style.backgroundColor='white'; AllowOnlyFloat('form_','other_amt');"
							style="text-align:right" /></td>
          </tr>
      </table></td>
    </tr>
    <tr>
      <td height="56" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr>
            <td width="732" height="57" valign="top" bgcolor="#FFFFFF">Machine Validation/Revenue Official Receipt Details(If not filed with the bank)</td>
          </tr>
      </table></td>
    </tr>
  </table>
	<%}%>
</form>	
</body>
</html>
<%
dbOP.cleanUP();
%>