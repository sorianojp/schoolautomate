<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn,
								hr.HRInfoLeave"%>

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
<title>Leave Record</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
	TD{
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 10px;	
	}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

</style>
</head>
<script language="JavaScript">

function AddRecord(){
	document.form_.page_action.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}


</script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	boolean bolMyHome = false;

//add security hehol.

	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_personnel_education.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
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

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","LEAVE APPLICATION",request.getRemoteAddr(),
														"leave_apply.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		else 
			iAccessLevel = 1;

		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//
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
Vector vEmpRec = null;
Vector vEditResult = null;
boolean bNoError = false;
boolean bolSetEdit = false;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strIsWithPay = "0";
String strTenure = null;
String strNature = "";

HRInfoLeave hrPx = new HRInfoLeave();

int iAction =  -1;

if (WI.fillTextValue("emp_id").length()> 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if (vEmpRec == null){
		strErrMsg = authentication.getErrMsg();
	}else{
		strTenure = "select status from user_status where is_for_student = 0 " +
							 	" and status_index = " + (String)vEmpRec.elementAt(10);
		strTenure = dbOP.getResultOfAQuery(strTenure, 0);
		strTenure = WI.getStrValue(strTenure);
	}
}

vEditResult = hrPx.operateOnLeaveApplication(dbOP, request, 3);
if (vEditResult == null){
	strErrMsg = hrPx.getErrMsg();
}

//Vector vAllowedLeave = hrPx.getAllowedLeave(dbOP, request);
Vector vAllowedLeave = hrPx.getAvailableLeaveForSemNew(dbOP, request);
Vector vApplicableLeaves = hrPx.getApplicableLeaves(dbOP);


String[] astrConvertAMPM={" AM"," PM"};
String[] astrCurrentStatus ={"Disapproved", "Approved", "Pending/On-process",
							 "Requires Approval of Vice-President", 
							 "Requires Approval of President"};
String strSem = null;
%>
<body onLoad="window.print()">
<% if (strErrMsg != null && strErrMsg.length() > 0) { %>
<%=strErrMsg%>

<%}else if (vEmpRec !=null && vEmpRec.size() > 0 && vEditResult != null && vEditResult.size() > 0){ %>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="65%">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td><table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
      <tr bgcolor="#FFFFFF">
        <td width="30%" height="25" align="right" valign="middle"><img src="../../../images/logo/AUF_bw.jpg" width="50" height="75">                
        <td width="40%" height="25" valign="middle"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font><br>
                <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
                <strong>HUMAN RESOURCES DEVELOPMENT CENTER</strong><br>
          <br>
          </div>        
        <td width="30%" height="25" valign="middle">      </tr>
      <tr bgcolor="#FFFFFF">
        <td height="25" colspan="3" align="center" valign="middle"><strong><font size="2">LEAVE REQUEST FORM </font></strong></td>
      </tr>
      <tr bgcolor="#FFFFFF">
        <td height="25" colspan="3" align="center" valign="middle">&nbsp;</td>
      </tr>
      
    </table></td>
  </tr>
  <tr>
    <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="9%" height="22">NAME :</td>
        <td width="15%" valign="bottom" class="thinborderBottom"><%=(String)vEmpRec.elementAt(3)%></td>
        <td width="25%" valign="bottom" class="thinborderBottom"><%=(String)vEmpRec.elementAt(1)%></td>
        <td width="10%" valign="bottom" class="thinborderBottom"><%=WI.getStrValue((String)vEmpRec.elementAt(2))%></td>
        <td width="10%">&nbsp;</td>
        <td width="10%">Date Filed:</td>
        <td width="16%" align="center" class="thinborderBottom"><strong><%=WI.getStrValue((String)vEditResult.elementAt(3))%><br>
        </strong></td>
        <td width="5%">&nbsp;</td>
      </tr>
      <tr>
        <td height="22">&nbsp;</td>
        <td align="center">Last name </td>
        <td align="center">First Name </td>
        <td align="center">MI.</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td><table width="90%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td colspan="7" height="20">Status: (Please Check)</td>
      </tr>
      <tr>
        <%
					strTemp = WI.getStrValue((String)vEmpRec.elementAt(23), "2");
					if(strTemp.equals("1"))
						strTemp2 = "X";
					else
					 	strTemp2 = "&nbsp;";
				%>			
        <td width="12%" height="22" nowrap>[<%=strTemp2%>] Faculty</td>
				<%
					if(strTemp.equals("0"))
						strTemp2 = "X";
					else
					 	strTemp2 = "&nbsp;";					
				%>				
        <td width="24%" nowrap>[<%=strTemp2%>] Non Teaching Personnel </td>
				<%
					if(strTemp.equals("2"))
						strTemp2 = "X";
					else
					 	strTemp2 = "&nbsp;";					
				%>					
        <td width="8%" nowrap>[<%=strTemp2%>] Others</td>
				
        <td width="9%" class="thinborderBottom">&nbsp;</td>
        <td width="9%" nowrap>College/Unit:</td>
        <%
			if((String)vEmpRec.elementAt(13) == null)
				strTemp = WI.getStrValue((String)vEmpRec.elementAt(14));
			else{
				strTemp =WI.getStrValue((String)vEmpRec.elementAt(13));
				if((String)vEmpRec.elementAt(14) != null)
					 strTemp += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
			}
		%>
        <td width="28%" class="thinborderBottom"><strong><%=strTemp%> </strong></td>
        <td width="10%">&nbsp;</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td><table width="80%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="6%" height="22">&nbsp;</td>
        <%
					strTemp = WI.getStrValue((String)vEmpRec.elementAt(22));
					if(strTemp.equals("1")){
						if(strTenure.toUpperCase().indexOf("REGULAR") != -1)													
							strTemp2 = "X";
						else
							strTemp2 = "&nbsp;";
					}else
					 	strTemp2 = "&nbsp;";						
				%>	
        <td width="25%">[<%=strTemp2%>]Full-time, Regular </td>
				<%
					if(strTemp.equals("1")){
						if(strTenure.toUpperCase().indexOf("REGULAR") == -1)													
							strTemp2 = "X";
						else
							strTemp2 = "&nbsp;";
					}else
					 	strTemp2 = "&nbsp;";				
				%>				
        <td width="27%">[<%=strTemp2%>]Full-time, Probationary </td>
				<%
					if(!strTemp.equals("1"))
						strTemp2 = "X";
					else
						strTemp2 = "&nbsp;";								
				%>				
        <td width="42%">[<%=strTemp2%>]Part-Time</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td><table width="80%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="10%">Duration:</td>
        <td width="7%" align="right">From</td>
        <td width="15%" align="center" class="thinborderBottom"><%=(String)vEditResult.elementAt(10)%></td>
        <td width="2%">&nbsp;</td>
        <% strTemp =  WI.getStrValue((String)vEditResult.elementAt(11));
			if (strTemp.length() > 0) {
				if (WI.getStrValue((String)vEditResult.elementAt(12), "00").length() < 2){
					strTemp += ":0" + WI.getStrValue((String)vEditResult.elementAt(12), "00");
				}else{
					strTemp += ":" + WI.getStrValue((String)vEditResult.elementAt(12), "00");
				}			
				strTemp += astrConvertAMPM[Integer.parseInt(WI.getStrValue((String)vEditResult.elementAt(13),"0"))];
			}
		%>
        <td width="11%" align="center" class="thinborderBottom"><%=strTemp%></td>
        <td width="7%" align="right">To</td>
        <% strTemp = WI.getStrValue((String)vEditResult.elementAt(14));%>
        <td width="15%" align="center" class="thinborderBottom"><%=strTemp%></td>
        <td width="2%">&nbsp;</td>
        <%  strTemp =  WI.getStrValue((String)vEditResult.elementAt(15));
			if (strTemp.length() > 0) {
 				if (WI.getStrValue((String)vEditResult.elementAt(16), "00").length() < 2){
					strTemp += ":0" + WI.getStrValue((String)vEditResult.elementAt(16), "00");
				}else{
					strTemp += ":" + WI.getStrValue((String)vEditResult.elementAt(16), "00");
				}
		
				strTemp += astrConvertAMPM[Integer.parseInt(WI.getStrValue((String)vEditResult.elementAt(17),"0"))] ;
			}
		%>
        <td width="11%" align="center" class="thinborderBottom"><%=strTemp%></td>
        <td width="20%">&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td align="center">Date</td>
        <td>&nbsp;</td>
        <td align="center">Time</td>
        <td>&nbsp;</td>
        <td align="center">Date</td>
        <td>&nbsp;</td>
        <td align="center">Time</td>
        <td>&nbsp;</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td><table width="80%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="28%">Total No. of days/hrs leave </td>
        <td width="25%" class="thinborderBottom">
				<%	
					strTemp = WI.getStrValue((String)vEditResult.elementAt(22),"0");
					if(((String)vEditResult.elementAt(46)).equals("1"))
						strTemp += " hour(s)";
					else
						strTemp += " day(s)"; 
				%>
    <%=strTemp%></td>
        <td width="23%">Existing Leave Credits </td>
        <td width="19%" class="thinborderBottom">&nbsp;</td>
        <td width="5%">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="2">(to be filled out by requester)</td>
        <td colspan="2">(to be filled out by HRDC)</td>
        <td>&nbsp;</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="10%">NATURE:</td>
        <td width="20%"><table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
		<%
			strTemp = WI.getStrValue((String)vEditResult.elementAt(42),"Leave Without Pay");
			if(strTemp.toUpperCase().indexOf("SICK") != -1){
				strNature = (String)vEditResult.elementAt(45);
				strNature = WI.getStrValue(strNature);
			}
			System.out.println("strNature --- " + strNature);
			if(strNature.equals("0"))
				strTemp2 = "X";
			else
				strTemp2 = "&nbsp;";
		%>
    <td width="46%" nowrap>[<%=strTemp2%>]Sick Leave</td>
    <td width="54%" class="thinborderBottom">&nbsp;</td>
  </tr>
</table>
</td>
        <td width="70%"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="12%">Illness:</td>
            <td width="41%" class="thinborderBottom">&nbsp;</td>
            <td width="15%">Noted By: </td>
            <td width="32%" class="thinborderBottom">&nbsp;</td>
          </tr>
          <tr>
            <td height="16">&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td align="center">University Physician </td>
          </tr>
        </table></td>
        </tr>
      <tr>
        <td>&nbsp;</td>
        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
						<tr>
							<%
							if(strNature.equals("1"))
								strTemp2 = "X";
							else
								strTemp2 = "&nbsp;";							
							%>
							<td width="46%" nowrap>[<%=strTemp2%>]Emergency Leave</td>
							<td width="54%" class="thinborderBottom">&nbsp;</td>
						</tr>
					</table> 
				</td>
        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="15%" nowrap>Sickness of: </td>
            <td width="64%" class="thinborderBottom">&nbsp;</td>
            <td width="21%">&nbsp;</td>
          </tr>
        </table></td>
        </tr>
      <tr>
        <td>&nbsp;</td>
        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
						<tr>
							<%
							if(strNature.equals("2"))
								strTemp2 = "X";
							else
								strTemp2 = "&nbsp;";							
							%>						
							<td width="46%" nowrap>[<%=strTemp2%>]Personal Leave</td>
							<td width="54%" class="thinborderBottom">&nbsp;</td>
						</tr>
					</table></td>
        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="28%" nowrap>Please Specify reason(s)</td>
            <td width="51%" class="thinborderBottom"><strong>&nbsp;<%=WI.getStrValue((String)vEditResult.elementAt(23))%></strong></td>
            <td width="21%">&nbsp;</td>
          </tr>
        </table></td>
        </tr>
				<%if(vApplicableLeaves != null && vApplicableLeaves.size() > 0){%>
      <tr>
        <td>&nbsp;</td>
        <td colspan="2">				
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
					<% 
					strTemp = (String)vEditResult.elementAt(48);					
					strTemp = WI.getStrValue(strTemp);
					for(int i = 0 ; i < vApplicableLeaves.size(); i+=7) {
						if(((String)vApplicableLeaves.elementAt(i+1)).toUpperCase().indexOf("SICK") != -1)
							continue;
						if(strTemp.equals((String)vApplicableLeaves.elementAt(i)))
							strTemp2 = "X";
						else
							strTemp2 = "&nbsp;";
					%>
            <td width="5%" nowrap>[<%=strTemp2%>]<%=(String)vApplicableLeaves.elementAt(i+1)%></td>
					  <td width="7%" class="thinborderBottom">&nbsp;</td>
					  <td width="*">&nbsp;</td>
					  <%}%>
          </tr>
        </table>				
				</td>
        </tr>
				<%}%>
      <tr>
        <td height="10" colspan="3"></td>
        </tr>
    </table></td>
  </tr>
  <tr>
    <td><table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
      <tr>
        <td width="1%" class="thinborder">&nbsp;</td>
        <td width="20%" class="thinborderBottom"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td colspan="2">For Maternity Leave : </td>
            </tr>
          <tr>
            <td colspan="2">&nbsp;</td>
          </tr>
				<%
				strTemp = WI.getStrValue((String)vEditResult.elementAt(56),"3");
				if(strTemp.equals("0"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";
				%>					
          <tr>
            <td colspan="2">1. Type of Delivery : [<%=strTemp2%>]Normal </td>
            </tr>
          <tr>
					<%
					if(strTemp.equals("1"))
						strTemp2 = "X";
					else
						strTemp2 = "&nbsp;";					
					%>					
            <td width="46%">[<%=strTemp2%>]Cesarian</td>
					<%
					if(strTemp.equals("2"))
						strTemp2 = "X";
					else
						strTemp2 = "&nbsp;";					
					%>											
            <td width="54%">[<%=strTemp2%>]Miscarriage</td>
          </tr>
          <tr>
            <td colspan="2">&nbsp;</td>
          </tr>
          <tr>
            <td colspan="2">2. Number of previous deliveries </td>
            </tr>
          <tr>
            <td colspan="2">(miscarriage included, if any)&nbsp;<%=dbOP.mapOneToOther("HR_INFO_SP_CHILD", "user_index",(String)vEmpRec.elementAt(0), "count(*)", " and relation_index = 1 and is_del =0")%></td>
            </tr>
          <tr>
            <td colspan="2">&nbsp;</td>
          </tr>
          <tr>
            <td colspan="2">3. Present number of children : <strong><%=dbOP.mapOneToOther("HR_INFO_SP_CHILD", "user_index",(String)vEmpRec.elementAt(0), "count(*)", 
			" and relation_index = 1 and is_del =0")%></strong></td>
            </tr>
          <tr>
            <td colspan="2">&nbsp;</td>
          </tr>
          <tr>
            <td colspan="2">I hereby absolve AUF from
              any complications arising
              from my reporting for work
              during the duration of my
              maternity leave.</td>
            </tr>
        </table></td>
        <td width="1%" class="thinborder">&nbsp;</td>
        <td width="30%" valign="top" class="thinborderBottom"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td colspan="4" height="18">Signature of Requester: </td>
                </tr>
              <tr>
                <td class="thinborderBottom">&nbsp;</td>
                <td>&nbsp;</td>
                <td class="thinborderBottom">&nbsp;</td>
                <td>&nbsp;</td>
              </tr>
              <tr>
                <td width="46%">&nbsp;</td>
                <td width="8%">&nbsp;</td>
                <td width="36%" align="center">Date</td>
                <td width="10%">&nbsp;</td>
              </tr>
            </table></td>
            </tr>
          <tr>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td>Action Taken: </td>
            </tr>
          <tr>
            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td>&nbsp;</td>
                <td class="thinborderBottom">&nbsp;</td>
                <td>&nbsp;</td>
                <td class="thinborderBottom"><%=WI.getStrValue((String)vEditResult.elementAt(35),"&nbsp;")%></td>
              </tr>
              <tr>
                <td width="6%">&nbsp;</td>
                <td width="53%" align="center">Dean/Head</td>
                <td width="5%">&nbsp;</td>
                <td width="36%" align="center">Date</td>
              </tr>
              <tr>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
              </tr>
            </table></td>
          </tr>
          <tr>
            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
				<%
				strTemp = WI.getStrValue((String)vEditResult.elementAt(28),"3");
				if(strTemp.equals("1"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";
				%>
        <td width="40%" height="22">[<%=strTemp2%>] Approved</td>
				<%
				if(strTemp.equals("0"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";				
				%>								
        <td width="60%">[<%=strTemp2%>] Disapproved</td>
      </tr>
      <tr>
				<%
				strTemp = WI.getStrValue((String)vEditResult.elementAt(54),"2");
				if(strTemp.equals("1"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";
				%>
        <td colspan="2" height="22">[<%=strTemp2%>] Office/College Notified&nbsp;&nbsp;&nbsp;
				<%
				if(strTemp.equals("0"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";
				%>				
				[<%=strTemp2%>]&nbsp;Not Notified&nbsp;</td>
        </tr>
      <tr>
				<%
				strTemp = WI.getStrValue((String)vEditResult.elementAt(55),"2");
				if(strTemp.equals("1"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";
				%>
        <td height="22">[<%=strTemp2%>] Authorized</td>
				<%
				if(strTemp.equals("0"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";
				%>							
        <td>[<%=strTemp2%>] Not Authorized</td>
      </tr>
      <tr>
				<%
				strTemp = WI.getStrValue((String)vEditResult.elementAt(42),"Leave Without Pay");
				if(strTemp.equals("Leave Without Pay"))
					strIsWithPay = "0";
				else
					strIsWithPay = "1";
					
				if(strIsWithPay.equals("1"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";
				%>
        <td height="22">[<%=strTemp2%>] With Pay</td>
				<%
				if(strIsWithPay.equals("0"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";
				%>							
        <td>[<%=strTemp2%>] Without Pay</td>
      </tr>
    </table></td>
          </tr>
          <tr>
            <td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="20%" nowrap>Remarks:</td>
                <td width="77%" class="thinborderBottom">&nbsp;</td>
                <td width="3%">&nbsp;</td>
              </tr>
              <tr>
                <td>&nbsp;</td>
                <td >&nbsp;</td>
                <td >&nbsp;</td>
              </tr>
            </table>
						</td>
          </tr>
        </table></td>
        <td width="1%" class="thinborder">&nbsp;</td>
        <td width="24%" valign="top" class="thinborderBottom"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td colspan="5" height="18">&nbsp;</td>
                </tr>
              <tr>
                <td width="14%">&nbsp;</td>
                <td width="48%" class="thinborderBottom">&nbsp;</td>
                <td width="4%">&nbsp;</td>
                <td width="28%" class="thinborderBottom"><%=WI.getStrValue((String)vEditResult.elementAt(36),"&nbsp;")%></td>
                <td width="6%">&nbsp;</td>
              </tr>
              <tr>
                <td>&nbsp;</td>
                <td align="center">VP Concerned </td>
                <td>&nbsp;</td>
                <td align="center">Date</td>
                <td>&nbsp;</td>
              </tr>
            </table></td>
          </tr>
          <tr>
            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
				<%
				strTemp = WI.getStrValue((String)vEditResult.elementAt(29),"3");
				if(strTemp.equals("1"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";
				%>				
          <td width="40%" height="22">[<%=strTemp2%>] Approved</td>
				<%
				if(strTemp.equals("0"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";				
				%> 			
          <td width="60%">[<%=strTemp2%>] Disapproved</td>
        </tr>
        <tr>
				<%
				strTemp = WI.getStrValue((String)vEditResult.elementAt(52),"2");
				if(strTemp.equals("1"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";
				%>				
          <td height="22">[<%=strTemp2%>] With Pay</td>
				<%
				if(strTemp.equals("0"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";
				%>					
          <td>[<%=strTemp2%>] Without Pay</td>
        </tr>
      </table></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="33%">Remarks:</td>
                <td width="67%" class="thinborderBottom">&nbsp;</td>
              </tr>
            </table></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td>&nbsp;</td>
                <td class="thinborderBottom">&nbsp;</td>
                <td>&nbsp;</td>
                <td class="thinborderBottom"><%=WI.getStrValue((String)vEditResult.elementAt(37),"&nbsp;")%> </td>
                <td>&nbsp;</td>
              </tr>
              <tr>
                <td width="9%">&nbsp;</td>
                <td width="46%" align="center">President</td>
                <td width="4%">&nbsp;</td>
                <td width="32%" align="center">Date</td>
                <td width="9%">&nbsp;</td>
              </tr>
            </table></td>
          </tr>
          <tr>
            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
<%
				strTemp = WI.getStrValue((String)vEditResult.elementAt(30),"3");
				if(strTemp.equals("1"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";
				%>				
          <td width="40%" height="22">[<%=strTemp2%>] Approved </td>
				  <%
				if(strTemp.equals("0"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";				
				%> 
        <td width="60%">[<%=strTemp2%>]&nbsp;Disapproved&nbsp; </td>
      </tr>
      <tr>
				<%
				strTemp = WI.getStrValue((String)vEditResult.elementAt(53),"2");
				if(strTemp.equals("1"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";
				%>			
        <td height="22">[<%=strTemp2%>] With Pay</td>
				<%
				if(strTemp.equals("0"))
					strTemp2 = "X";
				else
					strTemp2 = "&nbsp;";
				%>				
        <td>[<%=strTemp2%>] Without Pay</td>
      </tr>
    </table></td>
          </tr>
          <tr>
            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="25%" nowrap>Remarks:</td>
                <td width="72%" class="thinborderBottom">&nbsp;</td>
                <td width="3%">&nbsp;</td>
              </tr>
            </table></td>
          </tr>
          <tr>
            <td height="10"></td>
          </tr>
        </table></td>
        <td width="1%" class="thinborder">&nbsp;</td>
        <td width="22%" valign="top" class="thinborderBottom"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="94%"><table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td colspan="3" height="18">&nbsp;</td>
                </tr>
              <tr>
                <td width="48%" class="thinborderBottom">&nbsp;</td>
                <td width="4%">&nbsp;</td>
                <td width="28%" class="thinborderBottom">&nbsp;</td>
                </tr>
              <tr>
                <td align="center">HR Assistant  </td>
                <td>&nbsp;</td>
                <td align="center">Date</td>
                </tr>
            </table></td>
            <td width="6%">&nbsp;</td>
          </tr>
          <tr>
            <td heig><table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="34%" height="22" nowrap>Available leave :</td>
                <td width="66%" class="thinborderBottom">&nbsp;</td>
              </tr>
            </table></td>
            <td heig>&nbsp;</td>
          </tr>
          <tr>
            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="54%" height="22" nowrap>No. of hrs. leave:</td>
                <td width="46%" class="thinborderBottom">&nbsp;</td>
              </tr>
            </table></td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="30%" height="22" nowrap>Balance:</td>
                <td width="70%" class="thinborderBottom">&nbsp;</td>
              </tr>
            </table></td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="25%" height="22" nowrap>For SD:</td>
                <td width="75%" class="thinborderBottom">&nbsp;</td>
              </tr>
            </table></td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="34%" height="22" nowrap>Remarks:</td>
                <td width="66%" class="thinborderBottom">&nbsp;</td>
              </tr>
            </table></td>
            <td>&nbsp;</td>
          </tr>
          
          <tr>
            <td>Noted By : </td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td width="48%" class="thinborderBottom">&nbsp;</td>
                <td width="4%">&nbsp;</td>
                <td width="28%" class="thinborderBottom">&nbsp;</td>
                </tr>
              <tr>
                <td align="center">HRDC Director </td>
                <td>&nbsp;</td>
                <td align="center">Date</td>
                </tr>
            </table></td>
            <td>&nbsp;</td>
          </tr>
        </table></td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="3%">N.B.</td>
        <td width="97%">(1) Application for leave of absence should be forwarded to the HRDC not later than two working days upon return, otherwise absence/absences
          incurred will be considered Absence Without Official Leave (AWOL) and therefore subject to salary deduction.</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>(2) In cases of emergency leave, a minimum of one (1) hour must be filed,a fraction of an hour will still be counted as one (1) hour</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>(3) * In cases of Vacation Leave application, an approved letter of request from the President is required.</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>(4) Application of Maternity Leave could be a week before scheduled date of delivery or not later than two weeks after delivery date / miscarriage.</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
  </td>
    <td width="35%" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td colspan="2" valign="top"><table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
          <tr bgcolor="#FFFFFF">
            <td width="15%" height="25" align="right" valign="middle"><img src="../../../images/logo/AUF_bw.jpg" width="50" height="75"></td>
						<td width="75%" height="25" valign="middle">
							<div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font><br>
              <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
              <strong>HUMAN RESOURCES DEVELOPMENT CENTER</strong><br><br>
              </div></td>
						</tr>
          <tr bgcolor="#FFFFFF">
            <td height="25" colspan="2" align="center" valign="middle"><strong><font size="2">LEAVE REQUEST FORM </font></strong></td>
          </tr>
        </table></td>
      </tr>
      <tr>
        <td colspan="2"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td width="57%" align="right">Date filed:</td>
            <td width="36%" align="center" class="thinborderBottom"><strong><%=WI.getStrValue((String)vEditResult.elementAt(3))%></strong></td>
            <td width="7%">&nbsp;</td>
          </tr>
        </table></td>
      </tr>
      <tr>
        <td height="22">&nbsp;</td>
        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="17%">Name : </td>
            <td colspan="2" class="thinborderBottom"><%=WI.formatName((String)vEmpRec.elementAt(1), (String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3), 4)%></td>
            <td width="6%">&nbsp;</td>
          </tr>
          
        </table></td>
      </tr>
      <tr>
        <td height="22">&nbsp;</td>
        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
          
          <tr>
            <td colspan="2">College/Unit:</td>
            <%
							if((String)vEmpRec.elementAt(13) == null)
								strTemp = WI.getStrValue((String)vEmpRec.elementAt(14));
							else{
								strTemp =WI.getStrValue((String)vEmpRec.elementAt(13));
								if((String)vEmpRec.elementAt(14) != null)
									 strTemp += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
							}
						%>
            <td width="80%" class="thinborderBottom"><strong><%=strTemp%> </strong></td>
            <td width="6%">&nbsp;</td>
          </tr>
          
        </table></td>
      </tr>
      <tr>
        <td width="5%" height="22">&nbsp;</td>
        <td width="95%"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="14%">Duration:</td>
            <td width="9%" align="right">From</td>
            <td width="17%" align="center" class="thinborderBottom"><%=(String)vEditResult.elementAt(10)%></td>
            <% strTemp =  WI.getStrValue((String)vEditResult.elementAt(11));
			if (strTemp.length() > 0) {
				if (WI.getStrValue((String)vEditResult.elementAt(12), "00").length() < 2){
					strTemp += ":0" + WI.getStrValue((String)vEditResult.elementAt(12), "00");
				}else{
					strTemp += ":" + WI.getStrValue((String)vEditResult.elementAt(12), "00");
				}			
				strTemp += astrConvertAMPM[Integer.parseInt(WI.getStrValue((String)vEditResult.elementAt(13),"0"))];
			}
		%>
            <td width="13%" align="center" class="thinborderBottom"><%=strTemp%></td>
            <td width="5%" align="right">To</td>
            <% strTemp = WI.getStrValue((String)vEditResult.elementAt(14));%>
            <td width="17%" align="center" class="thinborderBottom"><%=strTemp%></td>
            <%  strTemp =  WI.getStrValue((String)vEditResult.elementAt(15));
			if (strTemp.length() > 0) {
 				if (WI.getStrValue((String)vEditResult.elementAt(16), "00").length() < 2){
					strTemp += ":0" + WI.getStrValue((String)vEditResult.elementAt(16), "00");
				}else{
					strTemp += ":" + WI.getStrValue((String)vEditResult.elementAt(16), "00");
				}
		
				strTemp += astrConvertAMPM[Integer.parseInt(WI.getStrValue((String)vEditResult.elementAt(17),"0"))] ;
			}
		%>
            <td width="13%" align="center" class="thinborderBottom"><%=strTemp%></td>
            <td width="8%">&nbsp;</td>
          </tr>
          
        </table></td>
      </tr>
      <tr>
        <td height="22">&nbsp;</td>
        <td>Nature:</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
						<%
						System.out.println("strNature == " + strNature);
							if(strNature.equals("0"))
								strTemp2 = "X";
							else
								strTemp2 = "&nbsp;";
						%>					
            <td width="20%" nowrap>[<%=strTemp2%>]Sick Leave</td>
            <td width="73%" class="thinborderBottom">&nbsp;</td>
            <td width="7%" height="22">&nbsp;</td>
          </tr>
          <tr>
						<%
							if(strNature.equals("1"))
								strTemp2 = "X";
							else
								strTemp2 = "&nbsp;";
						%>						
            <td nowrap>[<%=strTemp2%>]Emergency</td>
            <td class="thinborderBottom">&nbsp;</td>
            <td height="22">&nbsp;</td>
          </tr>
          <tr>
						<%
							if(strNature.equals("2"))
								strTemp2 = "X";
							else
								strTemp2 = "&nbsp;";
						%>						
            <td colspan="2">[<%=strTemp2%>]Personal Leave (Please specify reason(s)): </td>
            <td height="22">&nbsp;</td>
          </tr>
          <tr>
            <td colspan="2" class="thinborderBottom"><strong><%=WI.getStrValue((String)vEditResult.elementAt(23))%></strong></td>
            <td height="22">&nbsp;</td>
          </tr>
					<%if(vApplicableLeaves != null && vApplicableLeaves.size() > 0){%>
          <tr>
            <td colspan="2"><table width="100%" border="0" cellspacing="0" cellpadding="0">
					<% 
					strTemp = (String)vEditResult.elementAt(48);
					strTemp = WI.getStrValue(strTemp);
					for(int i = 0 ; i < vApplicableLeaves.size(); i+=7) {
						if(((String)vApplicableLeaves.elementAt(i+1)).toUpperCase().indexOf("SICK") != -1)
							continue;

						if(strTemp.equals((String)vApplicableLeaves.elementAt(i)))
							strTemp2 = "X";
						else
							strTemp2 = "&nbsp;";
					%>
          <tr>
            <td width="25%" nowrap>[<%=strTemp2%>]<%=(String)vApplicableLeaves.elementAt(i+1)%></td>
					  <td width="75%" class="thinborderBottom">&nbsp;</td>					  
          </tr>
					<%}%>
        </table></td>
            <td height="22">&nbsp;</td>
          </tr>
					<%}%>
        </table></td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <td>(To be filled-out by HRDC)</td>
      </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="25%" nowrap>Available Leave:</td>
            <td width="67%" class="thinborderBottom">&nbsp;</td>
            <td width="8%">&nbsp;</td>
          </tr>
          
        </table></td>
      </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
          
          <tr>
            <td width="30%" nowrap>No. of hours/days:</td>
            <td width="62%" class="thinborderBottom">&nbsp;</td>
            <td width="8%">&nbsp;</td>
          </tr>
          
        </table></td>
      </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
          
          <tr>
            <td width="10%" nowrap>Balance:</td>
            <td width="82%" class="thinborderBottom">&nbsp;</td>
            <td width="8%">&nbsp;</td>
          </tr>
          
        </table></td>
      </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
          
          <tr>
            <td width="30%" nowrap>For Salary Deduction:</td>
            <td width="62%" class="thinborderBottom">&nbsp;</td>
            <td width="8%">&nbsp;</td>
          </tr>
          
        </table></td>
      </tr>
      <tr>
        <td height="20">&nbsp;</td>
        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
          
          <tr>
            <td width="15%" nowrap>Remarks:</td>
            <td width="79%" class="thinborderBottom">&nbsp;</td>
            <td width="6%">&nbsp;</td>
          </tr>
        </table></td>
      </tr>
      <tr>
        <td colspan="2">&nbsp;</td>
      </tr>
      <tr>
        <td>&nbsp;</td>
        <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="51%">Verified by :</td>
            <td width="4%">&nbsp;</td>
            <td width="35%">&nbsp;</td>
            <td width="10%">&nbsp;</td>
          </tr>
          <tr>
            <td height="39" class="thinborderBottom">&nbsp;</td>
            <td>&nbsp;</td>
            <td class="thinborderBottom">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td align="center">HR Assistant</td>
            <td>&nbsp;</td>
            <td align="center">Date</td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td>Noted by: </td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td height="35" class="thinborderBottom">&nbsp;</td>
            <td>&nbsp;</td>
            <td class="thinborderBottom">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td align="center">HRDC Director</td>
            <td>&nbsp;</td>
            <td align="center">Date</td>
            <td>&nbsp;</td>
          </tr>
        </table></td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td width="70%"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="60%">AUF-Form-HRDC-PERS-05</td>
        <td colspan="2">Received by: </td>
        <td width="26%" class="thinborderBottom">&nbsp;</td>
        <td width="1%">&nbsp;</td>
      </tr>
      <tr>
        <td>April 1, 2009 Rev-01</td>
        <td width="6%">Date:</td>
        <td colspan="2" class="thinborderBottom">&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
    </table></td>
    <td><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="60%">AUF-Form-HRDC-PERS-05</td>
        </tr>
      <tr>
        <td>April 1, 2009 Rev-01</td>
        </tr>
    </table></td>
  </tr>
</table>

<% } %>
</body>
</html>
<%
	dbOP.cleanUP();
%>
