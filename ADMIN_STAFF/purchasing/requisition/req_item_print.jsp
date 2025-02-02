<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
 div.processing{
    display:block;

    /*set the div in the bottom right corner*/
    position:absolute;
    right:0;
	top:0;
    /*give it some background and border
    background:#007fb7;*/
	background:#FFFFFF;
   
  }


TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
}
TABLE.thinborderALL {
    border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
}
TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderLeft {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderRight {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBottomRight {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderALL {
    border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.NoBorder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<body onLoad="window.print()" topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,purchasing.Requisition,java.util.Vector" %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	strSchCode = "UB";
	if(strSchCode.startsWith("VMA")){%>
		<jsp:forward page="./req_item_print_vma.jsp"></jsp:forward>
<%	return;}
	if(strSchCode.startsWith("UB")){%>
		<jsp:forward page="./req_item_print_ub.jsp"></jsp:forward>
<%	return;}

	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION-Requisition Print","req_item_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	Requisition REQ = new Requisition();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strTemp = null;
	int iLoop = 2;
	int iCountRows = 0;
	double dTotalAmount = 0d;
	
	
	String strInfo5 = SchoolInformation.getInfo5(dbOP, false, false);	

	int iNumRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"15"));
	boolean bolShowPresident = false;
			
	vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);	
	if(vReqInfo == null)
		strErrMsg = REQ.getErrMsg();
	else{
		if(((String)vReqInfo.elementAt(3)).equals("0")){
		  if ((WI.getStrValue((String)vReqInfo.elementAt(9),"").toLowerCase()).equals("office of the president")){
			bolShowPresident = true;
		  }
		}
	}
	
	vReqItems = REQ.operateOnReqItems(dbOP,request,4);
	if(vReqItems != null)
	for(;iLoop < vReqItems.size();){
		iCountRows = 0;
		dTotalAmount = 0d;
%>
<form name="form_" method="post">
  <%if(vReqInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <%if(!strSchCode.startsWith("UI") && !strSchCode.startsWith("AUF")){%>
	 <%if(!strSchCode.startsWith("CLDH")){%>
     <tr> 
       <td height="25" align="center"><div align="left">&nbsp;</div>          
		 	<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br> 
		    <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br> 
		    <br> 
		    <%if(WI.fillTextValue("is_canvass").length() < 1){%> 
		    <font size="+2"><strong>REQUISITION FORM</strong></font> 
          <%}else{%> 
          <font size="+2"><strong>CANVASS FORM</strong></font> 
          <%}%> 
         <br>          <br> </td>
      </tr>
	 <%}// end if not CLDH%>
   <%}else{%>
    <tr> 
      <td height="25">&nbsp;<br> <br> <br> <br> <br></td>
    </tr>
   <%}// if the school code starts with UI %>
  </table>
  <%if(strSchCode.startsWith("CLDH")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="9%" rowspan="2" align="center" valign="top"><div align="left"><img src="../../../images/logo/CLDH.gif" width="70" height="70" border="0"></div></td>
        <td width="66%" rowspan="2" valign="top"> <strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br></td>
        <td height="25" colspan="3" valign="top"><DIV align="center">
          <table width="98%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
            <tr>
              <td class="thinborderALL"><div align="center"><strong><font face="Arial, Verdana,  Helvetica, sans-serif" size="2">PURCHASE REQUISITION </font></strong></div></td>
            </tr>
          </table>
        </div></td>
      </tr>      
      <tr>
        <td width="7%" valign="top">&nbsp;</td>
        <td width="7%" height="22"><div align="right"><font size="+1">No.</font>&nbsp;&nbsp;</div></td>
        <td width="11%" valign="bottom" class="thinborderBottom"><strong><font size="1">&nbsp;<%=WI.fillTextValue("req_no")%></font></strong></td>
      </tr>
      <tr>
        <td colspan="3" align="center" valign="top">
		  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
          <tr>
            <td width="18%" class="thinborder"><div align="right">Requisitioning<br>
            Department </div></td>
			<%if(((String)vReqInfo.elementAt(3)).equals("0"))
				strTemp = (String)vReqInfo.elementAt(9);
			  else
				strTemp = (String)vReqInfo.elementAt(8)+ "/" +WI.getStrValue((String)vReqInfo.elementAt(9),"All");
			%>			
            <td width="28%" class="thinborder">&nbsp;<%=strTemp%></td>
            <td width="18%" class="thinborder">Attention: <br>
            Purchasing Dept . </td>
            <td width="36%" class="thinborder"><span class="thinborder">Please purchase for our department the items enumerated below </span></td>
          </tr>
        </table></td>

        <td height="25"><div align="right">Date :&nbsp;&nbsp;</div></td>
        <td valign="bottom" class="thinborderBottom"><strong><font size="1">&nbsp;<%=(String)vReqInfo.elementAt(7)%></font></strong></td>
      </tr>
  </table>
  <%}
  if(strSchCode.startsWith("AUF")){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="26%" rowspan="4" align="right" valign="top"><img src="../../../images/logo/AUF_PAMPANGA.gif" width="70" height="70" border="0"></td>
        <td colspan="2" align="center" valign="top" style="font-size:14px;">Angeles University Foundation</td>
        <td height="18" colspan="2">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="2" align="center" valign="top" style="font-size:9px;">Angeles City, Phlippines<br>
		<font style="font-size:12px; font-weight:bold">
		PURCHASING AND SUPPLY OFFICE		</font>		</td>
        <td height="18" align="right" valign="bottom">&nbsp;</td>
        <td height="18" valign="bottom">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="2" rowspan="2" align="center"><strong><font size="+1">REQUISITION FORM</font></strong></td>
        <td height="25" align="right" valign="bottom">R.F No. </td>
        <td height="25" valign="bottom" class="thinborderBottom"><strong><font size="1"><%=WI.fillTextValue("req_no")%></font></strong></td>
      </tr>
      <tr>
        <td width="14%" height="25" align="right" valign="bottom">&nbsp;</td>
        <td width="14%" valign="bottom">&nbsp;</td>
      </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
            
      <tr>
        <td width="82%" colspan="3" align="center" valign="top">
		  <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="18%" class="NoBorder">College/Unit</td>
            <%if(((String)vReqInfo.elementAt(3)).equals("0"))
				strTemp = (String)vReqInfo.elementAt(9);
			  else
				strTemp = (String)vReqInfo.elementAt(8)+ "/" +WI.getStrValue((String)vReqInfo.elementAt(9),"All");
			%>			
            <td class="thinborderBottom">&nbsp;<%=strTemp%></td>
            <td width="36%">&nbsp;</td>
          </tr>
        </table></td>

        <td width="7%" height="25">&nbsp;</td>
        <td width="11%" valign="bottom">&nbsp;</td>
      </tr>
  </table>
  <%}
  if(!strSchCode.startsWith("CLDH") && !strSchCode.startsWith("AUF")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<%if(WI.fillTextValue("is_canvass").length() < 1){%>
    <tr> 
      <td height="17">&nbsp;</td>
      <td><font size="1">Requisition No.</font></td>
      <td><strong><font size="1"><%=WI.fillTextValue("req_no")%></font></strong></td>
      <td><font size="1">Requested By</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(2)%></font></strong></td>
    </tr>
    <tr> 
      <td width="2%" height="17">&nbsp;</td>
      <td width="18%"><font size="1">Request Type</font></td>
      <td width="31%"><font size="1"><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(1))]%></strong></font></td>
      <td width="15%"><font size="1">Purpose/Job</font></td>
      <td width="34%"><strong><font size="1"><%=(String)vReqInfo.elementAt(5)%></font></strong></td>
    </tr>
    <tr> 
      <td height="17">&nbsp;</td>
      <td><font size="1">Requisition Status</font></td>
      <td><strong><font size="1"><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(10))]%></font></strong></td>
      <td><font size="1">Requisition Date</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(7)%></font></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(3)).equals("0")){%>
    <tr> 
      <td height="17">&nbsp;</td>
      <td><font size="1">Office</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(9)%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></font></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="17">&nbsp;</td>
      <td><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(8)+"/"+WI.getStrValue((String)vReqInfo.elementAt(9),"All")%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></font></strong></td>
    </tr>
    <%} // end if  (((String)vReqInfo.elementAt(3)).equals("0"))
	}else{%>
	<tr> 
      <td height="17">&nbsp;</td>
      <td><font size="1">Canvassing No. </font></td>
      <td><strong><font size="1"><%=WI.fillTextValue("canvass_no")%></font></strong></td>
      <td><font size="1">Canvassing Date </font></td>
      <td><strong><font size="1"><%=WI.fillTextValue("canvass_date")%></font></strong></td>
    </tr>
	<%}// end if(WI.fillTextValue("is_canvass").length() < 1)%>
  </table>
  <%}// end if not CLDH
  if(vReqItems != null){%>
  <br>

  <%if(strSchCode.startsWith("CLDH")) {%>
  <table width="100%" border="0" class="thinborder" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
	<tr>
      <td  height="17" colspan="10" class="thinborder"><div align="center"><strong>LIST OF REQUESTED ITEMS</strong></div></td>
	</tr> 
    <tr> 
      <td width="4%" height="17" align="center" class="thinborder"><strong>ITEM #</strong></td>
      <td width="35%" align="center" class="thinborder"><strong>ITEM/PARTICULARS/DESCRIPTION </strong></td>
      <td width="7%" align="center" class="thinborder"><strong>DATE NEEDED </strong></td>
      <td width="6%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>TOTAL</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>TOTAL</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>TOTAL</strong></td>
    </tr>
    <% //System.out.println(iNumRows);	
		//System.out.println(vReqItems.size()/9);	
	for(;iLoop < vReqItems.size() && iCountRows < iNumRows;iLoop+=9,++iCountRows){%>
    <tr> 
      <td  height="17" class="thinborder"><div align="center"><%=(iLoop+7)/9%></div></td>
      <td class="thinborder">&nbsp;<%=vReqItems.elementAt(iLoop+3)%> / <%=vReqItems.elementAt(iLoop+4)%> </td>
      <td class="thinborder">&nbsp; </td>
      <td class="thinborder"><div align="left">
        <div align="right"><%=vReqItems.elementAt(iLoop+1)%>&nbsp;</div>
      </div></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
	  <td class="thinborder">&nbsp;</td>
	  <td class="thinborder">&nbsp;</td>
	  <td class="thinborder">&nbsp;</td>
	  <%if(vReqItems.elementAt(iLoop+7) != null)
	    	dTotalAmount += Double.parseDouble((String)vReqItems.elementAt(iLoop+7));%>
    </tr>
    <%}for(;iCountRows < iNumRows;++iCountRows){%>
    <tr> 
      <td height="17" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
	
    <tr> 
      <td  height="50" colspan="3"><div align="left">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="50%" class="thinborderLeft"><strong>Prepared by </strong></td>
            <td width="50%" class="thinborderLeft"><strong>Approved by </strong></td>
            </tr>
          <tr>
            <td height="19" class="thinborderLeft">&nbsp;</td>
            <td align="center" valign="bottom" class="thinborder">&nbsp; <strong>
              <%if(((String)vReqInfo.elementAt(3)).equals("0")){%>
              <font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(14),"").toUpperCase()%></font>
              <%}else{%>
              <font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(13),"").toUpperCase()%></font>
              <%}%>
            </strong></td>
          </tr>
          <tr>
            <td height="19" class="thinborder">&nbsp;</td>
            <td align="center" class="thinborder">Dept Head </td>
          </tr>
        </table>
      </div></td>
      <td colspan="2" class="thinborder"><strong>TOTALS</strong></td>
      <td class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">======</td>
      <td class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">======</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
  </table>  
	<%} else if(strSchCode.startsWith("AUF")) {%>
  <table width="100%" border="0" class="thinborderALL" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
	 
    <tr> 
      <td width="4%" height="17" align="center" class="thinborderBottomRight"><strong>Quantity</strong></td>
      <td width="35%" align="center" class="thinborderBottomRight"><strong>Name & Description of Item/s</strong></td>
      <td width="6%" align="center" class="thinborderBottomRight"><strong>Available</strong></td>
      <td width="8%" align="center" class="thinborderBottomRight"><strong>Not Available </strong></td>
      <td width="8%" align="center" class="thinborderBottom"><strong>Remarks</strong></td>
    </tr>
    <% //System.out.println(iNumRows);	
		//System.out.println(vReqItems.size()/9);	
	for(;iLoop < vReqItems.size() && iCountRows < iNumRows;iLoop+=9,++iCountRows){%>
    <tr> 
      <td  height="17" align="right" class="thinborderRight"><%=vReqItems.elementAt(iLoop+1)%>
        <%=vReqItems.elementAt(iLoop+2)%> </td>
      <td class="thinborderRight">&nbsp;<%=vReqItems.elementAt(iLoop+3)%> / <%=vReqItems.elementAt(iLoop+4)%> </td>
      <td class="thinborderRight">&nbsp;</td>
      <td class="thinborderRight">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
	  <%if(vReqItems.elementAt(iLoop+7) != null)
	    	dTotalAmount += Double.parseDouble((String)vReqItems.elementAt(iLoop+7));%>
    </tr>
    <%}for(;iCountRows < iNumRows;++iCountRows){%>
    <tr> 
      <td height="17" class="thinborderRight">&nbsp;</td>
      <td class="thinborderRight">&nbsp;</td>
      <td class="thinborderRight">&nbsp;</td>
      <td class="thinborderRight">&nbsp;</td>
      <td class="NoBorder">&nbsp;</td>
    </tr>
    <%}%>
  </table>  	
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50%" class="thinborderBottom" height="20" style="font-size:12px;">To be filled up by requester</td>
          <td width="50%" class="thinborderBottom" align="right" style="font-size:12px;">To be filled up by Purchasing &amp; Supply Office</td>
    </tr>
    <tr>
      <td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        
        <tr>
          <td width="15%">Purpose:</td>
          <td colspan="4" class="thinborderBottom"><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(5), "&nbsp;")%></font></strong></td>
          </tr>
        <tr>
          <td colspan="5">&nbsp;</td>
          </tr>
        <tr>
          <td colspan="2">Date Needed :</td>
          <td colspan="3"><strong><font size="1"><u><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></u></font></strong></td>
          </tr>
        <tr>
          <td colspan="2">Prepared by: </td>
          <td colspan="3">&nbsp;</td>
          </tr>
        <tr>
          <td colspan="3" class="thinborderBottom"><br>&nbsp;</td>
          <td width="4%">&nbsp;</td>
					<%
						strTemp = WI.fillTextValue("date_updated");
					%>
          <td width="49%" align="center" class="thinborderBottom" valign="bottom"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
        </tr>
        <tr>
          <td colspan="3" align="center">Dean/Head </td>
          <td>&nbsp;</td>
          <td align="center"> Date </td>
        </tr>
        <tr>
          <td colspan="5" class="NoBorder">
			  <div style="font-weight:bold">
			  cc: Requester, Purchasing & Supply Office<br>
			  AUF-FORM-AFO-30<br>
			  Aug. 1, 2007- Rev. 0			  </div>		  </td>
          </tr>
      </table></td>
      <td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        
        <tr>
          <td width="62%" align="right">&nbsp;</td>
          <td width="38%" colspan="2">/ &nbsp;/ Recommended </td>
          </tr>
        <tr>
          <td align="right">&nbsp;</td>
          <td colspan="2">/&nbsp; / Disapproved </td>
          </tr>    

      </table>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
          
          <tr>
            <td colspan="3" class="thinborderBottom"><br>&nbsp;</td>
            <td>&nbsp;</td>
            <td class="thinborderBottom">&nbsp;</td>
          </tr>
          <tr>
            <td colspan="3" align="center">Vice President Concerned </td>
            <td width="6%">&nbsp;</td>
            <td width="28%" align="center">Date</td>
          </tr>
        </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
          
          <tr>
            <td width="20%">&nbsp;</td>
            <td width="28%">Remark</td>
            <td width="24%">&nbsp;</td>
            <td width="28%">&nbsp;</td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>/ &nbsp;/ Urgent </td>
            <td>/ &nbsp;/ Justified </td>
            <td>/&nbsp; / Others </td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
        </table>				
	  </td>
    </tr>
  </table>	
	<%} else {%>
  <table width="100%" border="0" class="thinborder" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
	  <tr>
      <td  height="17" colspan="7" align="center" class="thinborder"><strong>LIST 
          OF REQUESTED ITEMS</strong></td>
	  </tr> 
    <tr> 
      <td width="5%" height="17" align="center" class="thinborder"><strong>ITEM #</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="35%" align="center" class="thinborder"><strong>ITEM/PARTICULARS/DESCRIPTION </strong></td>
      <td width="17%" align="center" class="thinborder"><strong>SUPPLIER</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>AMOUNT</strong></td>
    </tr>
    <% //System.out.println(iNumRows);	
		//System.out.println(vReqItems.size()/9);	
	for(;iLoop < vReqItems.size() && iCountRows < iNumRows;iLoop+=9,++iCountRows){%>
    <tr> 
      <td  height="17" class="thinborder"><div align="center"><%=(iLoop+7)/9%></div></td>
      <td class="thinborder"><div align="right"><%=vReqItems.elementAt(iLoop+1)%>&nbsp;</div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=vReqItems.elementAt(iLoop+3)%> / <%=vReqItems.elementAt(iLoop+4)%>
	  </div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=WI.getStrValue((String)vReqItems.elementAt(iLoop+5),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+6),"&nbsp;")%>&nbsp;</div></td>
      <td class="thinborder"><div align="right">
	  	<%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%>
		<%}%></div></td>
	  <%if(vReqItems.elementAt(iLoop+7) != null)
	    	dTotalAmount += Double.parseDouble((String)vReqItems.elementAt(iLoop+7));%>
    </tr>
    <%}
	
	strTemp = "********** NOTHING FOLLOWS **********";
	for(;iCountRows < iNumRows;++iCountRows){		
		if(strSchCode.startsWith("EAC") && strTemp != null){
	%>	
	<tr> 
      <td height="17" colspan="7" align="center" class="thinborder"><%=strTemp%></td>
      </tr>
	<%strTemp = null;}%>
    <tr> 
      <td height="17" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
	<tr> 
      <td height="17" colspan="5" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><strong>PAGE 
        AMOUNT : </strong></td>
      <td class="thinborder"><div align="right"><strong>
	  <%if(dTotalAmount > 0d){%>
	  <%=CommonUtil.formatFloat(dTotalAmount,true)%>
	  <%}else{%>
	  &nbsp;
	  <%}%>
	  </strong></div>	  </td>
    </tr>
    <tr> 
      <td  height="17" colspan="5" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=vReqItems.elementAt(0)%></strong></div></td>
      <td align="right" class="thinborder"><strong>TOTAL 
        AMOUNT : </strong></td>
      <td class="thinborder"><div align="right"><strong><%=vReqItems.elementAt(1)%></strong></div></td>
    </tr>
  </table>
	<%}// end else
	if(strSchCode.startsWith("SWU")){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td width="25%" align="center" class="thinborder" height="30" valign="bottom"><div style="text-align:left;">REQUESTED BY:</div><br><br><br><br>
				<div style="border-bottom:solid 1px #000000; text-align:center; width:97%">&nbsp;</div>&nbsp;</td>
			<td width="25%" align="center" class="thinborder" height="30" valign="bottom"><div style="text-align:left;">NOTED BY:</div><br><br><br><br>
				<div style="border-bottom:solid 1px #000000; text-align:center; width:97%">&nbsp;</div>&nbsp;</td>
			<td width="25%" align="center" class="thinborder" height="30" valign="bottom"><div style="text-align:left;">ENDORSED BY:</div><br><br><br><br>
				<div style="border-bottom:solid 1px #000000; text-align:center; width:97%">&nbsp;</div>&nbsp;</td>
			<td width="25%" align="center" class="thinborder" height="30" valign="bottom"><div style="text-align:left;">APPROVED BY:</div><br><br><br><br>
				<div style="border-bottom:solid 1px #000000; text-align:center; width:97%">&nbsp;</div>&nbsp;</td>
		</tr>
		<tr>
		    <td class="thinborder" height="19" valign="bottom">&nbsp;</td>
		    <td class="thinborder" rowspan="2" valign="top" align="center"><font size="1">COST CENTER DEAN/OFFICE HEAD</font></td>
		    <td class="thinborder" rowspan="2" valign="bottom">PROPERTY CUSTODIAN</td>
		    <td class="thinborder" rowspan="2" valign="bottom">VP FOR FINANCE</td>
	    </tr>
		<tr>
		    <td class="thinborder" align="center" height="18" valign="bottom">INDICATED DESIGNATION</td>		    
	    </tr>
	</table>
	<%}
	if(strSchCode.startsWith("CPU") || strSchCode.startsWith("TSUNEISHI")){
	if(WI.fillTextValue("is_canvass").length() < 1){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="16%" height="22" valign="bottom">Acct. No.:</td>
      <td width="27%" class="thinborderBottom">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="20%" valign="bottom">Requested by:</td>
      <td width="31%" valign="bottom" class="thinborderBottom"><div align="center"><strong><%=(String)vReqInfo.elementAt(2)%></strong></font></div></td>
      <td width="2%" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="32" valign="bottom">Funds Available:</td>
      <td valign="bottom" class="thinborderBottom">&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom">Recommending Approval:</td>
      <td valign="bottom" class="thinborderBottom"><div align="center">&nbsp; 
          <strong>
          <%if(((String)vReqInfo.elementAt(3)).equals("0")){%>
          <font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(14),"").toUpperCase()%></font> 
          <%}else{%>
          <font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(13),"").toUpperCase()%></font> 
          <%}%>
          </strong> </div></td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="32" rowspan="2" valign="bottom">Approved:</td>
      <td rowspan="2" valign="bottom" class="thinborderBottom"><div align="center">&nbsp;<strong>
	  <%if(bolShowPresident){%>
	  <%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"University President",7)),"").toUpperCase()%>
	  <%}%>	  
	  </strong></div></td>
      <td rowspan="2" valign="bottom">&nbsp;</td>
      <td rowspan="2" valign="bottom">Purchasing Officer:</td>
      <td align="center" valign="top"><font size="1">Unit 
        Head </font></td>
      <td rowspan="2" align="center" valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td align="center" valign="bottom" class="thinborderBottom"><font size="1"><strong><%=WI.formatName((String)vReqInfo.elementAt(16), (String)vReqInfo.elementAt(17),
							(String)vReqInfo.elementAt(18), 7).toUpperCase()%>&nbsp;</strong></font></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td align="center" valign="top"><font size="1">President</font></td>
      <td align="center" valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}else{// END IF IS CANVASS < 1%>    
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="18%" height="43" valign="bottom"><strong>CANVASSED BY : </strong></td>
      <td width="29%" class="thinborderBottom" valign="bottom" align="center">&nbsp;
	  <%if(strSchCode.startsWith("TSUNEISHI")){%>
	  <%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"Purchasing Officer",7)),"").toUpperCase()%>
	  <%}%>
	  </td>
      <td width="53%">&nbsp;</td>
    </tr>
    <tr>
      <td height="43" valign="top">&nbsp;</td>
      <td valign="top" align="center" style="font-size:9px;"><%if(strSchCode.startsWith("TSUNEISHI")){%>Purchasing Officer<%}%></td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}
  }
  else if(strSchCode.startsWith("UPH") && strInfo5 == null){
  %>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  	<tr>
		<td height="20" width="13%">Prepared By</td>
		<td width="39%">: <%=WI.getStrValue(vReqInfo.elementAt(24))%></td>
		<td width="14%">Noted By</td>
		<td width="34%">: <%=WI.getStrValue(vReqInfo.elementAt(25))%></td>
	</tr>
	<tr>
		<td height="20" width="13%"><!--Request By--></td>
		<td width="39%"><!--: <%=WI.getStrValue(vReqInfo.elementAt(2))%>--></td>
		<td width="14%">Endorsed By</td>
		<td width="34%">: <%=WI.getStrValue(vReqInfo.elementAt(26))%></td>
	</tr>
  </table>
  
<div id="processing" class="processing">
<table cellpadding="0" cellspacing="0" border="0" Width="100%" style="border:solid 1px #000000;">
	<tr>
		<td>UPHS-01-PROP-PRS-02</td>		
	</tr>
	<tr>
		<td>01-10-2010 &nbsp; &nbsp; &nbsp; REV.01</td>		
	</tr>	
</table>
</div>	  
  
  
  <%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
		<%if(strSchCode.startsWith("WNU")){
				if(WI.fillTextValue("is_canvass").length() < 1) // for requisition
					strTemp = "<br>Form No. : OP-BAF-02F01";
				else
					strTemp = "<br>Form No. : OP-BAF-02F07";// canvassing
				
				strTemp+="<br>Form Effectivity Date: January 25, 2010";
				strTemp+="<br>Form Revision/Issuance No.: 1/2";
			}else{
				strTemp = "&nbsp;";
			}
		%>		
      <td height="22"><font  style="font-family:Arial, Helvetica, sans-serif; font-size:9px;"><%=strTemp%></font></td>
    </tr>
  </table>
	<%if (iLoop < vReqItems.size()) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
	
    } // if(vReqItems != null)%
	%>
  <%} // if(vReqInfo != null)  	
	}// outermost for loop%>
	<input type="hidden" name="num_rows" value="<%=WI.fillTextValue("num_rows")%>">
</form>

</body>
</html>
<%
	dbOP.cleanUP();
%>